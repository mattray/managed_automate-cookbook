#
# Cookbook:: managed-automate2
# Recipe:: default
#

fcp = Chef::Config[:file_cache_path]
aibdir = node['ma2']['aib']['dir']
aibfile = aibdir + '/' + node['ma2']['aib']['file']
aibchef = aibdir + '/chef-automate'
licensefile = fcp + '/automate.license'

# if the aib file is not there download it
unless node['ma2']['aib']['url'].nil?
  remote_file aibfile do
    source node['ma2']['aib']['url']
    not_if { ::File.exist?(aibfile) }
  end
end

# get the license from a URL
unless node['ma2']['license']['url'].nil?
  remote_file licensefile do
    source node['ma2']['license']['url']
    not_if { ::File.exist?(licensefile) }
  end
end

# or get the license from a string
unless node['ma2']['license']['string'].nil?
  file licensefile do
    content node['ma2']['license']['string']
    sensitive true
    not_if { ::File.exist?(licensefile) }
  end
end

# prepare for preflight-check

# OK |  running as root
# OK |  volume: has 40GB avail (need 5GB for installation)
# OK |  automate not already deployed
# OK |  initial required ports are available
# OK |  init system is systemd
# OK |  found required command useradd
# OK |  system memory is at least 2000000 KB (2GB)
# OK |  fs.file-max must be at least 64000
# OK |  vm.max_map_count is at least 262144
# OK |  vm.dirty_ratio is between 5 and 30
# OK |  vm.dirty_background_ratio is between 10 and 60
# OK |  vm.dirty_expire_centisecs must be between 10000 and 30000

# fs.file-max is at least 64000
fs_file_max = `sysctl -n fs.file-max`.strip.to_i
sysctl_param 'fs.file-max' do
  value node['ma2']['sysctl']['fs.file-max']
  not_if { fs_file_max > 64000 }
end

# vm.max_map_count must be at least 262144
vm_max_map_count = `sysctl -n vm.max_map_count`.strip.to_i
sysctl_param 'vm.max_map_count' do
  value node['ma2']['sysctl']['vm.max_map_count']
  not_if { vm_max_map_count > 262144 }
end

# vm.dirty_ratio is between 5 and 30
vm_dirty_ratio = `sysctl -n vm.dirty_ratio`.strip.to_i
sysctl_param 'vm.dirty_ratio' do
  value node['ma2']['sysctl']['vm.dirty_ratio']
  not_if { (vm_dirty_ratio > 5) && (vm_dirty_ratio < 30) }
end

# vm.dirty_background_ratio is between 10 and 60
vm_dirty_background_ratio = `sysctl -n vm.dirty_background_ratio`.strip.to_i
sysctl_param 'vm.dirty_background_ratio' do
  value node['ma2']['sysctl']['vm.dirty_background_ratio']
  not_if { (vm_dirty_background_ratio > 10) && (vm_dirty_background_ratio < 60) }
end

# vm.dirty_expire_centisecs must be between 10000 and 30000
vm_dirty_expire_centisecs = `sysctl -n vm.dirty_expire_centisecs`.strip.to_i
sysctl_param 'vm.dirty_expire_centisecs' do
  value node['ma2']['sysctl']['vm.dirty_expire_centisecs']
  not_if { (vm_dirty_expire_centisecs > 10000) && (vm_dirty_expire_centisecs < 30000) }
end

# Verify the installation is ready to run Automate 2
execute "#{aibchef} preflight-check --airgap" do
  not_if { ::File.exist?("#{fcp}/config.toml") }
end

# create default configuration
execute "#{aibchef} init-config --upgrade-strategy none" do
  cwd fcp
  not_if { ::File.exist?("#{fcp}/config.toml") }
end

# deploy chef automate
execute 'chef-automate deploy' do
  command "#{aibchef} deploy config.toml --accept-terms-and-mlsa --skip-preflight --airgap-bundle #{aibfile}"
  cwd fcp
  not_if { ::File.exist?("#{fcp}/automate-credentials.toml") }
end

execute 'chef-automate license apply' do
<<<<<<< HEAD
<<<<<<< HEAD
  command "#{aibchef} license apply #{licensefile}"
=======
=======
>>>>>>> c299b0ae94a6e72038b3b9a2c66cdc51b19f5c67
  command "#{aibchef} license apply #{node['ma2']['license']}"
  sensitive true
  not_if { node['ma2']['license'].nil? }
>>>>>>> Changes for cookstyle compliance
  not_if "#{aibchef} license status | grep '^License ID'"
end

# should we push the contents of automate-credentials.toml into an attribute or
# log if we don't want logins on the box?
# should we push the admin-token for later? ruby-block to an attribute?
