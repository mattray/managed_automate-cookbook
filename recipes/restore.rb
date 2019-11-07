#
# Cookbook:: managed_automate
# Recipe:: restore
#

# PREFLIGHT-CHECK
include_recipe 'managed_automate::_preflight_check'

# RESTORE
automate_airgap_install 'Restore Chef Automate' do
  install_file node['ma']['install']['file']
  install_url node['ma']['install']['url']
  restore_file node['ma']['restore']['file']
  restore_url node['ma']['restore']['url']
  chef_automate node['ma']['chef-automate']
  not_if { node['ma']['restore']['file'].nil? && node['ma']['restore']['url'].nil? }
  action :restore
end

# TUNE ELASTICSEARCH
include_recipe 'managed_automate::_elasticsearch'

# LICENSE
automate_license 'Apply Chef Automate license' do
  file node['ma']['license']['file']
  string node['ma']['license']['string']
  url node['ma']['license']['url']
  chef_automate node['ma']['chef-automate']
  action :apply
end
