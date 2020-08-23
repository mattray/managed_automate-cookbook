# # encoding: utf-8

# Inspec test for recipe managed_automate::default
control 'default tests' do
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

  describe file '/tmp/kitchen/cache/config.toml' do
    it { should exist }
    it { should be_file }
    its('content') { should match(/upgrade_strategy = "none"/) }
  end

  describe file '/tmp/kitchen/cache/automate-credentials.toml' do
    it { should exist }
    it { should be_file }
    its('content') { should match(/username = "admin"/) }
  end

  # elasticsearch
  # vm.swappiness should be 1
  describe kernel_parameter('vm.swappiness') do
    its('value') { should be 1 }
  end

  describe file '/tmp/kitchen/cache/elasticsearch_config.toml' do
    it { should exist }
    it { should be_file }
    #  its('content') { should match(/heapsize = "2902m"/) }
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
    its('stdout') { should match /^event-service           running        ok/ }
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
    its('stdout') { should match /CLI Build: / }
    its('stdout') { should match /Server Build: / }
  end
end

# minor differences in platforms
control 'centos tests' do
  only_if { os.redhat? }
  describe command('chef-automate config show') do
    its('stdout') { should match /cert = \"-----BEGIN CERTIFICATE-----/ }
    its('stdout') { should match /deployment_type = \"local\"$/ }
    its('stdout') { should match /heapsize = \"2902m\"$/ }
  end
end

control 'ubuntu tests' do
  only_if { os.debian? }
  describe command('chef-automate config show') do
    its('stdout') { should match /cert = \"-----BEGIN CERTIFICATE-----/ }
    its('stdout') { should match /deployment_type = \"local\"$/ }
    its('stdout') { should match /heapsize = \"2980m\"$/ }
  end
end
