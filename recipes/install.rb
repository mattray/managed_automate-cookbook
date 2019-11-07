#
# Cookbook:: managed_automate
# Recipe:: install
#

# PREFLIGHT-CHECK
include_recipe 'managed_automate::_preflight_check'

# INSTALL
automate_airgap_install 'Install Chef Automate' do
  install_file node['ma']['install']['file']
  install_url node['ma']['install']['url']
  chef_automate node['ma']['chef-automate']
  only_if { node['ma']['restore']['file'].nil? && node['ma']['restore']['url'].nil? }
  action :install
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
