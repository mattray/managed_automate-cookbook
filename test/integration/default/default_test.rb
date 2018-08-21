# # encoding: utf-8

# Inspec test for recipe managed-automate2::default

# fs.file-max is at least 64000
describe kernel_parameter('fs.file-max') do
  its('value') { should be >= 64000 }
end

# vm.max_map_count must be at least 262144
describe kernel_parameter( 'vm.max_map_count') do
  its('value') { should be >= 262144 }
end

# vm.dirty_ratio is between 5 and 30
describe kernel_parameter( 'vm.dirty_ratio') do
  its('value') { should be > 5 }
  its('value') { should be < 30 }
end

# vm.dirty_background_ratio is between 10 and 60
describe kernel_parameter( 'vm.dirty_background_ratio') do
  its('value') { should be > 10 }
  its('value') { should be < 60 }
end

# vm.dirty_expire_centisecs must be between 10000 and 30000
describe kernel_parameter( 'vm.dirty_expire_centisecs') do
  its('value') { should be >= 10000 }
  its('value') { should be <= 30000 }
end

describe file "/tmp/kitchen/cache/preflight-check" do
  it { should exist }
  it { should be_file }
end

describe file "/tmp/kitchen/cache/config.toml" do
  it { should exist }
  it { should be_file }
  its('content') { should match(/upgrade_strategy = "none"/) }
end
