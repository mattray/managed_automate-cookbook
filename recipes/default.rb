#
# Cookbook:: managed_automate
# Recipe:: default
#

# PREFLIGHT-CHECK
include_recipe 'managed_automate::_preflight_check'

# INSTALL
automate_airgap_install 'Install Chef Automate' do
  install_file node['ma']['install']['file']
  install_url node['ma']['install']['url']
  chef_automate node['ma']['chef-automate']
  not_if { node['ma']['restore']['file'] || node['ma']['restore']['url'] }
  action :install
end

# RESTORE
automate_airgap_install 'Restore Chef Automate' do
  install_file node['ma']['install']['file']
  install_url node['ma']['install']['url']
  restore_file node['ma']['restore']['file']
  restore_url node['ma']['restore']['url']
  chef_automate node['ma']['chef-automate']
  only_if { node['ma']['restore']['file'] || node['ma']['restore']['url'] }
  action :restore
end

# UPGRADE
automate_airgap_install 'Upgrade Chef Automate' do
  install_file node['ma']['upgrade']['file']
  install_url node['ma']['upgrade']['url']
  chef_automate node['ma']['chef-automate']
  only_if { node['ma']['upgrade']['file'] || node['ma']['upgrade']['url'] }
  action :upgrade
end

# TUNE ELASTICSEARCH
include_recipe 'managed_automate::_elasticsearch'

# LICENSING
# automate_license 'apply Chef Automate license' do
#   license_file
#   license_string
#   action :install
# end
