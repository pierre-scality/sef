'''
Created on 24 oct. 2013

@author: Christophe Vedel <christophe.vedel@scality.com>
'''

def slog(msg):
    __salt__['scalutils.slog'](msg)

def listening(name,
              address,
              port=8184,
              max_retry=20):
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Process is listening on {0}:{1}'.format(address, port)}
    result = __salt__['scalutils.check_process_listening'](address, port, max_retry) # @UndefinedVariable
    if result < 0:
        ret['result'] = False
        ret['comment'] = 'No process is listening on {0}:{1} ({2})'.format(address, port, -result)
    slog('[DEBUG] rest connector listening %s' % (ret['comment']))
    return ret


def declared(name,
        address,
        port,
        ssl=0
        ):
    '''
    Ensure that a rest connector is declared to sagentd
    
    name
        the name of the connector to declare

    address
        the address of the connector to declare

    port
        the port of the connector to declare

    ssl
        use SSL to control this connector

    '''
        
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': 'Rest connector already declared to sagentd'
    }
    if __salt__['scalutils.declare_rest_connector'](
            name=name,
            address=address,
            port=port,
            ssl=ssl,
            test=__opts__['test']
    ):
        ret['changes'][name] = 'Declared'
        ret['comment'] = 'Rest connector has been declared to sagentd'
        if __opts__['test']:
            ret['result'] = None
    slog('[DEBUG] connector declared %s' % (ret['comment']))
    return ret


def added(name,
          ring,
          supervisor,
          login,
          passwd):
    '''
    Ensure that a rest connector is added to a ring
    
    name
        the name of the connector to register (as defined in sagentd)
        
    ring
        the name of the ring

    supervisor
        the IP address or host name of the supervisor to register with            
        
    login
        login for the supervisor

    passwd
        password for the supervisor

    '''
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'RS2 connector belongs to ring {0}'.format(ring)}
    
    if not __salt__['scalutils.ringsh_at_least']('4.2'):  # @UndefinedVariable
        ret['comment'] = 'Adding a rest connector to a ring is not supported by your version of ringsh/pyscality'
        ret['result'] = False
        slog('[DEBUG] rest connector added %s' % (ret['comment']))
        return ret

    current_ring = __salt__['scalutils.get_rest_connector_ring'](name, supervisor, login=login, passwd=passwd)  # @UndefinedVariable
    if ring == current_ring:  # @UndefinedVariable
        slog('[DEBUG] rest connector added %s' % (ret['comment']))
        return ret
    
    if __opts__['test']:  # @UndefinedVariable
        msg = 'RS2 connector must be added to ring {0}'.format(ring)
        if current_ring:
            msg += ' (must be removed from ring {0} first)'.format(current_ring)
        ret['result'] = None
        ret['comment'] = msg
        slog('[DEBUG] rest connector added %s' % (ret['comment']))
        return ret
    
    if current_ring:
        if not __salt__['scalutils.remove_rest_connector'](name, current_ring, supervisor, login=login, passwd=passwd):  # @UndefinedVariable
            ret['comment'] = 'Failed to remove RS2 connector from ring {0}'.format(current_ring)
            ret['result'] = False
            slog('[DEBUG] rest connector added %s' % (ret['comment']))
            return ret

    if __salt__['scalutils.add_rest_connector'](name, ring, supervisor, login=login, passwd=passwd):  # @UndefinedVariable
        if current_ring:
            ret['comment'] = 'RS2 connector has been moved from ring {1} to ring {0}'.format(ring, current_ring)
            ret['changes'][name] = 'Moved'
        else:
            ret['comment'] = 'RS2 connector has been added to ring {0}'.format(ring)
            ret['changes'][name] = 'Added'
    else:
        ret['comment'] = 'Failed to add RS2 connector to ring {0}'.format(ring)
        ret['result'] = False
    slog('[DEBUG] rest connector added %s' % (ret['comment']))
    return ret

def configured(name,
               ring,
               supervisor,
               login,
               passwd,
               values=None,
               context=None,
               defaults=None):
    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'RS2 connector configuration OK'}
    try:
        mergedvalues = __salt__['scalutils.merge_values'](defaults, context, values)
        ret['changes'] = __salt__['scalutils.ov_configure'](name, supervisor, mergedvalues, ring=ring, test=__opts__['test'], login=login, passwd=passwd) # @UndefinedVariable
        if len(ret['changes']) > 0:
            if __opts__['test']: # @UndefinedVariable
                ret['result'] = None
                ret['comment'] = 'RS2 connector configuration must be changed'
            else:
                ret['comment'] = 'RS2 connector configuration changed'
    except Exception, exc:
        ret['result'] = False
        ret['comment'] = repr(exc)
    slog('[DEBUG] rest connector configured %s' % (ret['comment']))
    return ret
