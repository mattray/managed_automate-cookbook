input('version')

# fs.file-max is at least 64000
describe kernel_parameter('fs.file-max') do
  its('value') { should be >= 64000 }
end

# vm.max_map_count must be at least 262144
describe kernel_parameter('vm.max_map_count') do
  its('value') { should be >= 262144 }
end

# vm.dirty_ratio is between 5 and 30
describe kernel_parameter('vm.dirty_ratio') do
  its('value') { should be > 5 }
  its('value') { should be < 30 }
end

# vm.dirty_background_ratio is between 10 and 60
describe kernel_parameter('vm.dirty_background_ratio') do
  its('value') { should be > 10 }
  its('value') { should be < 60 }
end

# vm.dirty_expire_centisecs must be between 10000 and 30000
describe kernel_parameter('vm.dirty_expire_centisecs') do
  its('value') { should be >= 10000 }
  its('value') { should be <= 30000 }
end

# elasticsearch
# vm.swappiness should be 1
describe kernel_parameter('vm.swappiness') do
  its('value') { should be 1 }
end

# minor differences in platforms
control 'centos tests' do
  only_if { os.redhat? }

  describe file '/var/opt/chef-automate/backups/restore.toml' do
    its('content') { should match(/^\[global\.v1\]$/) }
    its('content') { should match(/^fqdn = \"/) }
    its('content') { should match(/^\[elasticsearch\.v1\.sys\.runtime\]$/) }
    its('content') { should match(/^heapsize = \"2902m\"$/) }
  end

  describe file '/tmp/kitchen/cache/elasticsearch_config.toml' do
    its('content') { should match(/^\[elasticsearch\.v1\.sys\.runtime\]$/) }
    its('content') { should match(/heapsize = "2902m"/) }
  end

  describe command('chef-automate config show') do
    its('stdout') { should match /cert = \"-----BEGIN CERTIFICATE-----/ }
    its('stdout') { should match /deployment_type = \"local\"$/ }
    its('stdout') { should match /heapsize = \"2902m\"$/ }
  end
end

control 'ubuntu tests' do
  only_if { os.debian? }

  describe file '/var/opt/chef-automate/backups/restore.toml' do
    its('content') { should match(/^\[global\.v1\]$/) }
    its('content') { should match(/^fqdn = \"/) }
    its('content') { should match(/^\[elasticsearch\.v1\.sys\.runtime\]$/) }
    its('content') { should match(/^heapsize = \"2980m\"$/) }
  end

  describe file '/tmp/kitchen/cache/elasticsearch_config.toml' do
    its('content') { should match(/^\[elasticsearch\.v1\.sys\.runtime\]$/) }
    its('content') { should match(/heapsize = "2980m"/) }
  end

  describe command('chef-automate config show') do
    its('stdout') { should match /cert = \"-----BEGIN CERTIFICATE-----/ }
    its('stdout') { should match /deployment_type = \"local\"$/ }
    its('stdout') { should match /heapsize = \"2980m\"$/ }
  end
end

describe command('chef-automate') do
  it { should exist }
end

describe command('chef-automate status') do
  its('stdout') { should match /^applications-service    running        ok/ }
  its('stdout') { should match /^authn-service           running        ok/ }
  its('stdout') { should match /^authz-service           running        ok/ }
  its('stdout') { should match /^automate-dex            running        ok/ }
  its('stdout') { should match /^automate-elasticsearch  running        ok/ }
  its('stdout') { should match /^automate-es-gateway     running        ok/ }
  its('stdout') { should match /^automate-gateway        running        ok/ }
  its('stdout') { should match /^automate-load-balancer  running        ok/ }
  its('stdout') { should match /^automate-pg-gateway     running        ok/ }
  its('stdout') { should match /^automate-postgresql     running        ok/ }
  its('stdout') { should match /^automate-ui             running        ok/ }
  its('stdout') { should match /^backup-gateway          running        ok/ }
  its('stdout') { should match /^cereal-service          running        ok/ }
  its('stdout') { should match /^compliance-service      running        ok/ }
  its('stdout') { should match /^config-mgmt-service     running        ok/ }
  its('stdout') { should match /^data-feed-service       running        ok/ }
  its('stdout') { should match /^deployment-service      running        ok/ }
  its('stdout') { should match /^es-sidecar-service      running        ok/ }
  its('stdout') { should match /^event-feed-service      running        ok/ }
  its('stdout') { should match /^event-gateway           running        ok/ }
  its('stdout') { should match /^event-service           running        ok/ }
  its('stdout') { should match /^infra-proxy-service     running        ok/ }
  its('stdout') { should match /^ingest-service          running        ok/ }
  its('stdout') { should match /^license-control-service running        ok/ }
  its('stdout') { should match /^local-user-service      running        ok/ }
  its('stdout') { should match /^nodemanager-service     running        ok/ }
  its('stdout') { should match /^notifications-service   running        ok/ }
  its('stdout') { should match /^pg-sidecar-service      running        ok/ }
  its('stdout') { should match /^secrets-service         running        ok/ }
  its('stdout') { should match /^session-service         running        ok/ }
  its('stdout') { should match /^teams-service           running        ok/ }
end

describe command('chef-automate license status') do
  its('stdout') { should match /^Licensed to:/ }
  its('stdout') { should match /^License ID:/ }
  its('stdout') { should match /^Expiration Date:/ }
end

describe command('chef-automate version') do
  its('stdout') { should include input('version').to_s }
end

# Event Feed
describe command('curl --insecure -H "api-token: sYKAqcY2H30ns7RTq7jCHNQ5vKs=" https://localhost/api/v0/eventfeed?page_size=100') do
  its('stdout') { should match /\"entity_name\":\"cis-centos7-level1-server version 2.2.0-15\",\"requestor_type\":\"User\",\"requestor_name\":\"admin\",\"service_hostname\":\"Not Applicable\"/ }
end

# Service Groups
describe command('curl --insecure -H "api-token: sYKAqcY2H30ns7RTq7jCHNQ5vKs=" https://localhost/api/v0/applications/service-groups') do
  its('stdout') { should match %r{\"application\":\"effortless\",\"environment\":\"home-lab\",\"package\":\"mattray/effortless-config-base\"} }
end

# All nodes are missing since the backup is old
describe command('curl --insecure -H "api-token: sYKAqcY2H30ns7RTq7jCHNQ5vKs=" https://localhost/api/v0/cfgmgmt/nodes?filter=status:missing') do
  its('stdout') { should match /\"source_fqdn\":\"ndnd.bottlebru.sh\",\"status\":\"missing\",\"timezone\":\"AEST\",\"uptime_seconds\"/ }
end

# Configuration
describe command('curl --insecure -s -H "api-token: sYKAqcY2H30ns7RTq7jCHNQ5vKs=" https://localhost/api/v0/cfgmgmt/nodes?sorting.field=name') do
  its('stdout') { should match /\"domain\":\"bottlebru.sh\",\"environment\":\"ndnd-home\",\"fqdn\":\"banjo.bottlebru.sh\"/ }
  its('stdout') { should match /\"dmi_system_manufacturer\":\"Shuttle Inc.\",\"dmi_system_serial_number\":\"To Be Filled By O.E.M.\",\"domain\":\"bottlebru.sh\",\"environment\":\"local\",\"fqdn\":\"crushinator.bottlebru.sh\",\"has_runs_data\":true,\"hostname\":\"crushinator\"/ }
end
