# Options to ctdbd, read by ctdbd_wrapper(1)
#
# See ctdbd.conf(5) for more information about CTDB configuration variables.

# Shared recovery lock file to avoid split brain.  No default.
#
# Do NOT run CTDB without a recovery lock file unless you know exactly
# what you are doing.
# CTDB_RECOVERY_LOCK=/some/place/on/shared/storage

# List of nodes in the cluster.  Default is below.
CTDB_NODES=/etc/ctdb/nodes

# List of public addresses for providing NAS services.  No default.
CTDB_PUBLIC_ADDRESSES=/etc/ctdb/public_addresses

# What services should CTDB manage?  Default is none.
CTDB_MANAGES_SAMBA=yes
CTDB_MANAGES_WINBIND=yes
#CTDB_MANAGES_NFS=yes

# Raise the file descriptor limit for CTDB?
# CTDB_MAX_OPEN_FILES=10000

# Default is to use the log file below instead of syslog.
CTDB_LOGGING=file:/var/log/samba/ctdb.log

# Default log level is NOTICE.  Want less logging?
CTDB_DEBUGLEVEL=NOTICE

# CTDB_SET_TDBMutexEnabled=1
CTDB_SERVICE_WINBIND="sernet-samba-winbindd"
CTDB_SERVICE_NMB="sernet-samba-nmbd"
CTDB_SERVICE_SMB="sernet-samba-smbd"

# Skip the check for the existence of each directory
# configured as share in Samba. This may be desirable
# if there is a large number of shares.
# Typically, you must disable the checks if you run
# Samba in combination with the GlusterFS VFS module.
# Default is no.
# CTDB_SAMBA_SKIP_SHARE_CHECK=yes

