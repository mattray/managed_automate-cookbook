# # encoding: utf-8

# Inspec test for recipe managed_automate::backup

# internal backup dir
describe directory('/var/opt/chef-automate/backups') do
  it { should exist }
end

# external backup dir
describe directory('/tmp/test/backups') do
  it { should exist }
end

describe file('/tmp/kitchen/cache/automate-backup.sh') do
  it { should exist }
  it { should be_executable }
end

# add crontab entry for cron[chef-automate backup create]
describe crontab do
  its('commands') { should include '/tmp/kitchen/cache/automate-backup.sh' }
end

describe crontab.commands('/tmp/kitchen/cache/automate-backup.sh') do
  its('minutes') { should cmp '*/5' }
  its('hours') { should cmp '*' }
  its('days') { should cmp '*' }
  its('months') { should cmp '*' }
  its('weekdays') { should cmp '*' }
end
