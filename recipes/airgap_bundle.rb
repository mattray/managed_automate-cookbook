#
# Cookbook:: managed_automate
# Recipe:: airgap_bundle
#

automate_cli 'download the chef-automate CLI' do
  directory node['ma']['aib']['dir']
  action :download
end

automate_airgap_bundle 'download the Automate airgap bundle' do
  directory node['ma']['aib']['dir']
  chef_automate node['ma']['aib']['dir'] + '/chef-automate'
  filename node['ma']['aib']['file']
  action :download
end
