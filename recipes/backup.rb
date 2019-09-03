#
# Cookbook:: managed_automate
# Recipe:: backup
#

# SCHEDULE
automate_backup 'Schedule Automate Backups' do
  backup_directory node['ma']['backup']['dir']
  export_directory node['ma']['backup']['export']['dir']
  export_prefix node['ma']['backup']['export']['prefix']
  minute node['ma']['backup']['cron']['minute']
  hour node['ma']['backup']['cron']['hour']
  day node['ma']['backup']['cron']['day']
  month node['ma']['backup']['cron']['month']
  weekday node['ma']['backup']['cron']['weekday']
  action :schedule
end
