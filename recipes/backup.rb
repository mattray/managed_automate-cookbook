#
# Cookbook:: managed-automate2
# Recipe:: backup
#
# https://automate.chef.io/docs/backup/#configuring-backups

# Configure A2 internal backups
intbackupdir = node['ma2']['backup']['internal']['dir']
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
extbackupdir = node['ma2']['backup']['external']['dir']
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
tar -czf #{extbackupdir}/#{node['ma2']['backup']['prefix']}${backup_id}.tgz backup-result.json $backup_id
rm -rf ${backup_id}"
end

# schedule backup on a recurring cron job. Override attributes as necessary
cron 'chef-automate backup create' do
  environment('PWD' => intbackupdir)
  command command
  minute node['ma2']['backup']['cron']['minute']
  hour node['ma2']['backup']['cron']['hour']
  day node['ma2']['backup']['cron']['day']
end
