input('version')

control 'nopreflight tests' do
  describe file '/tmp/kitchen/cache/config.toml' do
    its('content') { should match(/upgrade_strategy = "none"/) }
  end

  describe file '/tmp/kitchen/cache/automate-credentials.toml' do
    its('content') { should match(/username = "admin"/) }
  end

  # elasticsearch
  # vm.swappiness should be 1
  describe kernel_parameter('vm.swappiness') do
    its('value') { should be 1 }
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
    its('stdout') { should include input('version') }
  end
end

# minor differences in platforms
control 'centos tests' do
  only_if { os.redhat? }
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
