#
# Cookbook:: managed_automate
# Recipe:: airgap_bundle
#

automate_cli 'download the chef-automate CLI' do
  chef_automate node['ma']['chef-automate']
  action :download
end

automate_airgap_bundle 'download the Automate airgap bundle' do
  directory node['ma']['aib']['dir']
  filename node['ma']['aib']['file']
  chef_automate node['ma']['chef-automate']
  action :download
end
