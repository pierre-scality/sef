#
# ``svsd``: manage Virtual server service (aka SVSD)
# --------------------------------------------------
#
# By default, the installer top file ``/srv/scality/salt/local/installer_top.sls``
# associates this state with the **ROLE_SVSD** role. An easy way to assign this
# state to a minion is therefore to give it the **ROLE_SVSD** role,
# for example by running:
#
# .. code:: console
#
#   salt <minion_id> grains.append roles ROLE_SVSD
#
# Pillar variables
# ================
#
# These values are used in the zookeeper formula and can be tuned in
# the pillar files.
#
# global namespace
# ::::::::::::::::
#
# * ``scality:version``
#
# svsd namespace
# ::::::::::::::
#
# Default settings for these values are located in the ``scality/defaults.yaml``
# file in the root formula directory.
#
# * ``scality:svsd:net_iface``
#
# Available states
# ================
#
#  * installed       -> install packages only
#  * configured      -> configure the cluster and start the service
#
# .. note::
#
#   The ``configured`` state need to be executed when the zookeeper nodes
#    are up and running, otherwise states will fail.
#
# .. code:: text
#
#                       scality.svsd
#                            |
#                            |
#                        installed
#                            |
#                            |
#                        configured
#
#
# Example usage
# =============
#
# Svsd service need to be ran with at least one connector of nfs or cifs, so
# the svsd host need to have "ROLE_CONN_NFS" or "ROLE_CONN_CIFS". Otherwise
# svsd will be installed but stay unconfigured, and the service won't be
# started nor registered.
#
# 1. Add the role ROLE_SVSD to targeted machines
#
# .. code:: console
#
#   salt -L 'conn1,conn2,conn3' grains.append roles ROLE_SVSD
#
# 2. Install the virtual server
#
# .. code:: console
#
#   salt -G 'roles:ROLE_SVSD' state.sls scality.svsd
#
# 3. Configure and start the service
#
# .. code:: console
#
#   salt -G 'roles:ROLE_SVSD' state.sls scality.svsd.configured
#

include:
  - .installed
