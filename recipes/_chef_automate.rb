#
# Cookbook:: managed_automate
# Recipe:: _chef_automate
#

automate_cli 'download the chef-automate CLI' do
  chef_automate node['ma']['chef-automate']
  action :download
end
