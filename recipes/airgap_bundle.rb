# -*- coding: utf-8 -*-
#
# Cookbook:: managed-automate2
# Recipe:: airgap_bundle
#

package 'unzip'

remote_file 'chef-automate_linux_amd64.zip' do
  path "#{Chef::Config[:file_cache_path]}/chef-automate_linux_amd64.zip"
  source 'https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'
  not_if { ::File.exist?("#{node['ma2']['cli_path']}/chef-automate") }
end

# unzip the package
execute 'unzip chef-automate_linux_amd64.zip' do
  cwd Chef::Config[:file_cache_path]
  not_if { ::File.exist?("#{node['ma2']['cli_path']}/chef-automate") }
end

execute "cp #{Chef::Config[:file_cache_path]}/chef-automate #{node['ma2']['cli_path']}" do
  not_if { ::File.exist?("#{node['ma2']['cli_path']}/chef-automate") }
end

file "#{node['ma2']['cli_path']}/chef-automate" do
  mode '0755'
end

# successful execution of this command produces an Airgap Installation Bundle
execute "chef-automate airgap bundle create" do
  command "#{node['ma2']['cli_path']}/chef-automate airgap bundle create #{node['ma2']['aib']}"
  cwd Chef::Config[:file_cache_path]
  not_if { ::File.exist?( node['ma2']['aib'] ) }
end
