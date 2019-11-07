#
# Cookbook:: managed_automate
# Recipe:: upgrade
#

# PREFLIGHT-CHECK
include_recipe 'managed_automate::_preflight_check'

# UPGRADE
automate_airgap_upgrade 'Upgrade Chef Automate' do
  upgrade_file node['ma']['upgrade']['file']
  upgrade_url node['ma']['upgrade']['url']
  chef_automate node['ma']['chef-automate']
  not_if { node['ma']['upgrade']['file'].nil? && node['ma']['upgrade']['url'].nil? }
  action :upgrade
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
