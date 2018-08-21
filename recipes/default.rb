#
# Cookbook:: managed-automate2
# Recipe:: default
#

fcp = Chef::Config[:file_cache_path]

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
sysctl 'fs.file-max' do
  value node['ma2']['sysctl']['fs.file-max']
  not_if { 64000 < fs_file_max }
end

# vm.max_map_count must be at least 262144
vm_max_map_count = `sysctl -n vm.max_map_count`.strip.to_i
sysctl 'vm.max_map_count' do
  value node['ma2']['sysctl']['vm.max_map_count']
  not_if { 262144 < vm_max_map_count }
end

# vm.dirty_ratio is between 5 and 30
vm_dirty_ratio = `sysctl -n vm.dirty_ratio`.strip.to_i
sysctl 'vm.dirty_ratio' do
  value node['ma2']['sysctl']['vm.dirty_ratio']
  not_if { (5 < vm_dirty_ratio) && (vm_dirty_ratio < 30) }
end

# vm.dirty_background_ratio is between 10 and 60
vm_dirty_background_ratio = `sysctl -n vm.dirty_background_ratio`.strip.to_i
sysctl 'vm.dirty_background_ratio' do
  value node['ma2']['sysctl']['vm.dirty_background_ratio']
  not_if { (10 < vm_dirty_background_ratio) && (vm_dirty_background_ratio < 60) }
end

# vm.dirty_expire_centisecs must be between 10000 and 30000
vm_dirty_expire_centisecs = `sysctl -n vm.dirty_expire_centisecs`.strip.to_i
sysctl 'vm.dirty_expire_centisecs' do
  value node['ma2']['sysctl']['vm.dirty_expire_centisecs']
  not_if { (10000 < vm_dirty_expire_centisecs) && (vm_dirty_expire_centisecs < 30000) }
end

# Verify the installation is ready to run Automate 2
execute "#{node['ma2']['aib']['dir']}/chef-automate preflight-check --airgap" do
  not_if { ::File.exist?("#{fcp}/preflight-check") }
end

# disable repeated preflight-checks
file "#{fcp}/preflight-check" do
  action :nothing
  subscribes :create, "execute[#{node['ma2']['aib']['dir']}/chef-automate preflight-check --airgap]"
end

# create default configuration
execute "#{node['ma2']['aib']['dir']}/chef-automate init-config --upgrade-strategy none" do
  cwd fcp
  not_if { ::File.exist?("#{fcp}/config.toml") }
end

# Install all the things!
# ./chef-automate deploy config.toml
# sudo ./chef-automate deploy config.toml --accept-terms-and-mlsa --skip-preflight > ${GUEST_WKDIR}/logs/automate.deploy.log 2>&1

# if [ -f ${GUEST_WKDIR}/automate.license ]; then
#   sudo ./chef-automate license apply $(< ${GUEST_WKDIR}/automate.license) && sudo ./chef-automate license status
# fi
# sudo ./chef-automate admin-token > ${GUEST_WKDIR}/a2-token
