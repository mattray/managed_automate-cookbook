#
# Cookbook:: managed-automate2
# Recipe:: backup
#

# The backup is made to a directory tree under a hardcoded
# directory which is named by the timestamp of the time of
# backup.  This value appears to be significant during restore
# so we need to retain that timestamp.
#
# Optional output is the backup-result.json file which contains
# the timestamp.  We use and include this file when we create a
# tarball of the backup so we can correctly reconstruct the
# backup when restoring.

# where we store our backups
backupdir = node['ma2']['backup']['dir']

# where a2 creates its backups
a2backupdir = '/var/opt/chef-automate/backups'

backupcommand = a2backupdir + '/backup.sh'

directory backupdir

# shell script for backup
file backupcommand do
  mode '0700'
  content "#!/bin/sh

# work from a2's backup directory
cd #{a2backupdir}

# take backup
/usr/bin/chef-automate backup create --result-json backup-result.json

# backup_id is the timestamp as stored in the JSON log
backup_id=`cat backup-result.json | sed 's/.*backup_id\":\"\\([0-9]*\\).*/\\1/g'`

# tar the timestamped backup directory and JSON file
tar -czf #{backupdir}/#{node['ma2']['backup']['prefix']}${backup_id}.tgz backup-result.json $backup_id

# tidy up
rm -rf ${backup_id}

# that's all
"
end

# schedule backup on a recurring cron job. Override attributes as necessary
cron 'automate-ctl create-backup' do
  command "cd #{a2backupdir}; #{backupcommand} > /tmp/backup.log 2>&1"
  minute node['ma2']['backup']['cron']['minute']
  hour node['ma2']['backup']['cron']['hour']
  day node['ma2']['backup']['cron']['day']
end
