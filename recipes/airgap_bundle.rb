# -*- coding: utf-8 -*-
#
# Cookbook:: managed-automate2
# Recipe:: airgap_bundle
#

package 'unzip'

fcp = Chef::Config[:file_cache_path]
fcpfile = fcp + '/' + node['ma2']['aib']['file']
fcpchef = fcp + '/chef-automate'
aibdir = node['ma2']['aib']['dir']
aibfile = aibdir + '/' + node['ma2']['aib']['file']
aibchef = aibdir + '/chef-automate'

remote_file 'chef-automate_linux_amd64.zip' do
  path "#{fcp}/chef-automate_linux_amd64.zip"
  source 'https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'
  not_if { ::File.exist?(aibfile) && ::File.exist?(aibchef) }
end

# unzip the package
execute 'unzip chef-automate_linux_amd64.zip' do
  cwd fcp
  not_if { ::File.exist?(fcpchef) }
  not_if { ::File.exist?(aibfile) && ::File.exist?(aibchef) }
end

file fcpchef do
  mode '0755'
end

# copy chef-automate into the destination directory
execute "cp #{fcpchef} #{aibdir}" do
  not_if { ::File.exist?(aibchef) }
end

# successful execution of this command produces an Airgap Installation Bundle
execute 'chef-automate airgap bundle create' do
  command "#{fcpchef} airgap bundle create #{fcpfile}"
  cwd fcp
  not_if { ::File.exist?(fcpfile) }
  not_if { ::File.exist?(aibfile) }
end

# copy aib into the destination directory
execute "cp #{fcpfile} #{aibfile}" do
  not_if { ::File.exist?(aibfile) }
end
