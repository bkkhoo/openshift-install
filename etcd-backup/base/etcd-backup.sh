#!/bin/bash
#
# the script is designed to run as a cronJob in openshift cluster, it:
# 1. backups etcd data
# 2. transfers backup files (snopshot db and static resources) to a sftp server
#
# expects the following environment variables:
#   SFTP_SERVER - ip/hostname of sftp server; default 10.66.202.107
#   SFTP_PORT   - sftp/ssh port; default '-P 22'
#   SFTP_USERNAME - username to login to sftp serevr; default 'etcd-backup'
#   SSH_OPTIONS   - sftp/ssh options; default '-o StrictHostKeyChecking=no'

# sftp server config
_SFTP_SERVER="${SFTP_SERVER:-10.66.202.107}"
_SFTP_PORT="${SFTP_PORT:--P 22}"
_SFTP_USERNAME="${SFTP_USERNAME:-ectd-backup}"

# this is insecure, mount known_hosts if need secure
_SSH_OPTIONS="${SSH_OPTIONS:--o StrictHostKeyChecking=no}"

# this is mounted from openshift secret
SSH_PRIVATE_KEY="/etcd-backup/ssh-rsa-key"

# the same file in chroot and container filesystem
CHROOT_SSH_PRIVATE_KEY="/tmp/ssh-rsa-key"
HOST_SSH_PRIVATE_KEY="/host$CHROOT_SSH_PRIVATE_KEY"

# the same file in chroot and container filesystem
CHROOT_SFTP_BATCHFILE="/tmp/sft-batchfile"
HOST_SFTP_BATCHFILE="/host$CHROOT_SFTP_BATCHFILE"

# the same file in chroot and container filesystem
CHROOT_SOURCE_FOLDER="/home/core/assets/backup"
HOST_SOURCE_FOLDER="/host$CHROOT_SOURCE_FOLDER"

# backup etcd database; the command run under chroot
chroot /host /usr/local/bin/cluster-backup.sh $CHROOT_SOURCE_FOLDER

# get name of files created by cluster-backup.sh script
backup_files=$(ls -1 $HOST_SOURCE_FOLDER)

# create a sftp batchfile
rm -f $HOST_SFTP_BATCHFILE
for f in $(ls -1 $HOST_SOURCE_FOLDER); do
  echo "put $CHROOT_SOURCE_FOLDER/$f $BACKUP_PATH" >> $HOST_SFTP_BATCHFILE
done

# make sure $SSH_PRIVATE_KEY is available in chroot
cp $SSH_PRIVATE_KEY $HOST_SSH_PRIVATE_KEY
chmod 400 $HOST_SSH_PRIVATE_KEY

# transfer backup files to sftp server; the command run under chroot
chroot /host sftp -i $CHROOT_SSH_PRIVATE_KEY $_SSH_OPTIONS -b $CHROOT_SFTP_BATCHFILE $_SFTP_PORT $_SFTP_USERNAME@$_SFTP_SERVER

cat $HOST_SFTP_BATCHFILE
echo "$CHROOT_SSH_PRIVATE_KEY $_SSH_OPTIONS -b $CHROOT_SFTP_BATCHFILE $_SFTP_PORT $_SFTP_USERNAME@$_SFTP_SERVER"

# clean up
rm -rf $HOST_SOURCE_FOLDER $HOST_SFTP_BATCHFILE $HOST_SSH_PRIVATE_KEY
