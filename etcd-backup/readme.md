# Overview

The [Backing up etcd](https://docs.openshift.com/container-platform/4.14/backup_and_restore/control_plane_backup_and_restore/backing-up-etcd.html) OpenShift documentation describes the steps to backup etcd data. The backup script (`/usr/local/bin/cluster-backup.sh`) creates the he backup files (`snapshot_<datetimestamp>.db` and `static_kuberesources_<datetimestamp>.tar.gz`) on the master node. The cluster administrator has to provide the process to:
- copy/move the backup files to external backup server or location, and
- perform periodic etcd backup.

This repository contains the artifacts to deploy a cronJob to periodically backup etcd data, and copy the backup files to external SFTP server, using SSH key authentication. The [backup script](./base/etcd-backup.sh) can be easily modified to copy the backup files to persistent volume, instead of SFTP server.

**Notes**:
- OpenShift v4.14 has a tech preview feature to perform periodic etcd backup to persistent volume.

## Prerequisite

The following are required:
- SFTP server; RHEL systems comes with SSHd already installed and enabled.
- directory of the SFTP server to store backup files
- login username on the SFTP server
- ssh private key

Suggested steps:
1. create an SFTP user:
   ```
   sudo adduser --no-create-home --home-dir /opt/etcd-backup --shell /bin/bash etcd-backup
   ```
1. create directory to store backup files:
   ```
   sudo mkdir -p /opt/etcd-backup/{.ssh,dev-cluster}
   sudo chmod 700 /opt/etcd-backup/.ssh
   ```
1. create ssh key:
   ```
   sudo ssh-keygen -t rsa  -b 4096 -f /opt/etcd-backup/.ssh/id_rsa -P ""
   ```
1. authorize ssh key authentication:
   ```
   sudo cp .ssh/id_rsa.pub .ssh/authorized_keys
   ```
1. set files owner:
   ```
   sudo chown -R etcd-backup:etcd-backup /opt/etcd-backup
   ```

## Deploy cronJob

1. Copy ssh private key to [ssh-key file](./base/ssh-key)
1. Deploy:
   ```
   oc apply -k overlays/dev
   ```

**Notes**:
- The cronJob/script does not trim the number of backup files, configure cronjob on the SFTP server to delete old copies of the files. the example below delete old backup files, leaving only the newest 10 copies:
  ```
  ls -1tr /opt/etcd-backup/dev-cluster/snapshot_*.db | head -n -10 | xargs -d '\n' rm -f
  ls -1tr /opt/etcd-backup/dev-cluster/static_kuberesources_*.tar.gz | head -n -10 | xargs -d '\n' rm -f
  ```
