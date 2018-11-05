# # encoding: utf-8

# Inspec test for recipe managed-automate2::backup

# internal backup dir
describe directory('/tmp/A2backups') do
  it { should exist }
end

# external backup dir
describe directory('/tmp/backups') do
  it { should exist }
end

describe file('/tmp/A2backups/backup.sh') do
  it { should exist }
  it { should be_executable }
end

# add crontab entry for cron[knife ec backup]
describe crontab do
  its('commands') { should include '/tmp/A2backups/backup.sh' }
end

describe crontab.commands('/tmp/A2backups/backup.sh') do
  its('minutes') { should cmp '*/5' }
  its('hours') { should cmp '*' }
end
