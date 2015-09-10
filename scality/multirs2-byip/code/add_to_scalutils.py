
def declare_rest_connector(name, address, port, ssl=0, test=False):
    changed = True
    sagentd = {}
    with open('/etc/sagentd.yaml', 'r') as input:
        sagentd = yaml.load(input)
        todelete = []
        for n, value in sagentd['daemons'].iteritems():
            if name == n:
                if value.get('address', "") == address and \
                        value.get('port', 0) == port and \
                        value.get('ssl', 0) == ssl and \
                        value.get('type', "") == 'connector':
                    changed = False
            elif port == value.get('port', 0) and address == value.get('address', ""):
                # same address+port, different name, remove
                todelete.append(n)
        for n in todelete:
            del sagentd['daemons'][n]
            changed = True
        if changed:
            sagentd['daemons'][name] = {'address': address, 'port': port, 'ssl': ssl, 'type': 'connector'}

    if changed and len(sagentd) > 0:
        if not test:
            with open('/etc/sagentd.yaml', 'w') as output:
                slog('[DEBUG] Writing sagentd.yaml')
                output.write(yaml.dump(sagentd, default_flow_style=False))
        else:
            slog('[TEST] Writing sagentd.yaml')
        return True

    return False


@depends('supervisor', fallback_function=lambda: False)
def ctmpl_exists(name, ring, supervisor, login='root', passwd='admin'):
    '''
    Check whether an RS2 connector template exists or not.
    '''

    s = _get_supervisor(supervisor, login, passwd)

    if ring not in s.supervisorConfigMain().keys():
        msg = 'Ring {0} is not known by the supervisor'
        raise CommandExecutionError(msg.format(ring))

    infos = s.supervisorConfigDso(dsoname=ring)

    return infos.has_key('ctmpls') and infos['ctmpls'].has_key(name)


@depends('supervisor', fallback_function=lambda: False)
def create_ctmpl(name, ring, supervisor, login='root', passwd='admin'):
    '''
    Create an RS2 connector template.
    '''

    s = _get_supervisor(supervisor, login, passwd)

    if ring not in s.supervisorConfigMain().keys():
        msg = 'Ring {0} is not known by the supervisor'
        raise CommandExecutionError(msg.format(ring))

    try:
        res = s.supervisorConfigDso(action="addctmpl", dsoname=ring, extra_params={"ctmpl": name})
    except Exception, e:
        raise CommandExecutionError('Failed to create RS2 connector template {0} for ring {1} {2}'.format(name, ring, e))
    
    return True


@depends('supervisor', fallback_function=lambda: False)
def delete_ctmpl(name, ring, supervisor, login='root', passwd='admin'):
    '''
    Delete an RS2 connector template.
    '''

    s = _get_supervisor(supervisor, login, passwd)

    if ring not in s.supervisorConfigMain().keys():
        msg = 'Ring {0} is not known by the supervisor'
        raise CommandExecutionError(msg.format(ring))

    try:
        res = s.supervisorConfigDso(action="delctmpl", dsoname=ring, extra_params={"ctmpl": name})
    except Exception, e:
        raise CommandExecutionError('Failed to delete RS2 connector template {0} from ring {1} {2}'.format(name, ring, e))

    return True


@depends('supervisor', fallback_function=lambda: False)
def get_ctmpl(name, ring, supervisor, login='root', passwd='admin'):
    '''
    Read the configuration values for an RS2 connector template.
    '''

    s = _get_supervisor(supervisor, login, passwd)

    if ring not in s.supervisorConfigMain().keys():
        msg = 'Ring {0} is not known by the supervisor'
        raise CommandExecutionError(msg.format(ring))

    infos = s.supervisorConfigDso(dsoname=ring)

    if not infos.has_key('ctmpls') or not infos['ctmpls'].has_key(name):
        msg = 'RS2 connector template {0} in ring {1} is not known by the supervisor'
        raise CommandExecutionError(msg.format(name, ring))

    return infos['ctmpls'][name]


def _modctmpl(confname, confvalue, name, ring, s):
    intent = "add"
    if confvalue is None:
        intent = "del"
        confvalue = "1"
    elif type(confvalue) == type(0):
       confvalue = str(confvalue)
    elif confvalue[0] == '"' and confvalue[-1] == '"' and len(confvalue) >= 2:
        confvalue = confvalue[1:-1]

    try:
        res = s.supervisorConfigDso(action="modctmpl", dsoname=ring, extra_params={"ctmpl": name, "intent": intent, confname: confvalue})
    except Exception, e:
        msg = 'Failed to change parameter {2} of RS2 connector template {0} in ring {1} ({4})'
        raise CommandExecutionError(msg.format(name, ring, confname, e))


@depends('supervisor', fallback_function=lambda: False)
def configure_ctmpl(name, values, ring, supervisor, login='root', passwd='admin', test=False):
    s = _get_supervisor(supervisor, login, passwd)

    if ring not in s.supervisorConfigMain().keys():
        msg = 'Ring {0} is not known by the supervisor'
        raise CommandExecutionError(msg.format(ring))

    infos = s.supervisorConfigDso(dsoname=ring)

    if not infos.has_key('ctmpls') or not infos['ctmpls'].has_key(name):
        msg = 'RS2 connector template {0} in ring {1} is not known by the supervisor'
        raise CommandExecutionError(msg.format(name, ring))

    current = dict([(key, value) for key, _, value in infos['ctmpls'][name]])

    changes = {}
    for confname, confvalue in values.iteritems():
        if current.has_key(confname):
            if str(confvalue) != current[confname]:
                changes[confname] = 'created with value {0}'.format(confvalue)
                if not test:
                    _modctmpl(confname, confvalue, name, ring, s)
        else:
            changes[confname] = 'created with value {0}'.format(confvalue)
            if not test:
                _modctmpl(confname, confvalue, name, ring, s)
    for confname, confvalue in current.iteritems():
        if not values.has_key(confname):
            changes[confname] = 'deleted'
            if not test:
                _modctmpl(confname, None, name, ring, s)

    return changes
            
