#
# Cookbook:: managed_automate
# Recipe:: backup
#
# https://automate.chef.io/docs/backup/#configuring-backups

# Configure A2 internal backups
intbackupdir = node['ma']['backup']['internal']['dir']
directory intbackupdir

backupconfig = Chef::Config[:file_cache_path] + '/backup_config.toml'

template backupconfig do
  source 'backup_config.toml.erb'
end

execute "chef-automate config patch #{backupconfig}" do
  action :nothing
  subscribes :run, "template[#{backupconfig}]", :immediately
end

# Configure external backup storage
extbackupdir = node['ma']['backup']['external']['dir']
directory extbackupdir

# Schedule regular backups & copy via cron
command = intbackupdir + '/backup.sh'

# shell script for backup
file command do
  mode '0700'
  content "#!/bin/sh
cd #{intbackupdir}
/bin/chef-automate backup create --result-json backup-result.json > backup.log 2>&1
backup_id=`sed 's/.*backup_id\":\"\\([0-9]*\\).*/\\1/g' backup-result.json`
tar -czf #{extbackupdir}/#{node['ma']['backup']['prefix']}${backup_id}.tgz backup-result.json $backup_id
rm -rf ${backup_id}"
end

# schedule backup on a recurring cron job. Override attributes as necessary
cron 'chef-automate backup create' do
  environment('PWD' => intbackupdir)
  command command
  minute node['ma']['backup']['cron']['minute']
  hour node['ma']['backup']['cron']['hour']
  day node['ma']['backup']['cron']['day']
end
