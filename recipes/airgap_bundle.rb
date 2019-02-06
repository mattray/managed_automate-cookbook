# -*- coding: utf-8 -*-
#
# Cookbook:: managed-automate2
# Recipe:: airgap_bundle
#

package 'unzip'

fcp = Chef::Config[:file_cache_path]
fcpchef = fcp + '/chef-automate'
aibdir = node['ma2']['aib']['dir']
aibfile = aibdir + '/' + node['ma2']['aib']['file']
aibchef = aibdir + '/chef-automate'

remote_file "#{fcp}/chef-automate_linux_amd64.zip" do
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
  only_if { ::File.exist?(fcpchef) }
end

# copy chef-automate into the destination directory
execute "cp #{fcpchef} #{aibdir}" do
  not_if { ::File.exist?(aibchef) }
end

# successful execution of this command produces an Airgap Installation Bundle
execute "#{fcpchef} airgap bundle create" do
  cwd fcp
  # it would be nice to have a guard to only run daily
end

ruby_block "copy new AIB file to #{aibdir}" do
  block do
    previousaib = shell_out("ls -t1 #{aibdir} | grep [0-9].aib$ | head -1").stdout.strip
    newaib = shell_out("ls -t1 #{fcp} | grep [0-9].aib$ | head -1").stdout.strip
    puts "\nExisting AIB: #{previousaib}"
    puts "New AIB: #{newaib}"
    unless newaib.eql?(previousaib)
      require 'fileutils'
      newfile = fcp + '/' + newaib
      FileUtils.cp(newfile, aibdir)
      FileUtils.cp(newfile, aibfile)
    end
  end
end
