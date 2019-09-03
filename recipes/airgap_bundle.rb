#
# Cookbook:: managed_automate
# Recipe:: airgap_bundle
#

# CHEF-AUTOMATE
include_recipe 'managed_automate::_chef_automate'

automate_airgap_bundle 'download the Automate airgap bundle' do
  directory node['ma']['aib']['dir']
  filename node['ma']['aib']['file']
  chef_automate node['ma']['chef-automate']
  action :download
end
