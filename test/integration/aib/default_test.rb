# # encoding: utf-8

# Inspec test for recipe managed-automate2::airgap_bundle

fcpchef = attribute('fcpchef', default: '/tmp/chef-automate')
fcpfile = attribute('fcpfile', default: '/tmp/chef-automate-airgap.aib')
aibchef = attribute('aibchef', default: '/tmp/chef-automate')
aibfile = attribute('aibfile', default: '/tmp/chef-automate-airgap.aib')

describe package 'unzip' do
  it { should be_installed }
end

describe.one do
  describe file(aibchef) do
    it { should exist }
    it { should be_file }
  end

  describe file(fcpchef) do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0755' }
  end
end

describe.one do
  describe file(aibfile) do
    it { should exist }
    it { should be_file }
  end

  describe file(fcpfile) do
    it { should exist }
    it { should be_file }
  end
end
