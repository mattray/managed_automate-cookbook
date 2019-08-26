#
# Cookbook:: managed_automate
# Recipe:: default
#

fcp = Chef::Config[:file_cache_path]
chefautomate = node['ma']['aib']['dir'] + '/chef-automate'

# PREFLIGHT-CHECK
include_recipe 'managed_automate::_preflight_check'

# INSTALL, UPGRADE OR RESTORE?
installfile = node['ma']['aib']['dir'] + '/' + node['ma']['aib']['file']
installurl = node['ma']['aib']['url']

# is Automate already installed?
installed = false
upgrade = false
restore = false

# is Automate installed?
versions = shell_out("#{chefautomate} version").stdout.split
if versions[5].nil?
  currentversion = -1
else
  installed = true
  currentversion = versions[5]
end

# if we have an upgrade URL or we have an upgrade file and a directory, it's an upgrade
if node['ma']['upgrade']['url'] || (node['ma']['upgrade']['file'] && node['ma']['upgrade']['dir'])
  upgradeversion = node['ma']['upgrade']['version']
  upgradefile = node['ma']['upgrade']['dir'] + '/' + node['ma']['upgrade']['file']
  upgradeurl = node['ma']['upgrade']['url']
  upgrade = true
end

# if it's not installed but there is an upgrade, use the upgrade to install instead
if upgrade && !installed
  log 'INSTALL NOT AN UPGRADE'
  upgrade = false
  installfile = upgradefile
  installurl = upgradeurl
end

# is this a restore?
if node['ma']['restore']['file'] && node['ma']['restore']['dir']
  restorefile = node['ma']['restore']['dir'] + '/' + node['ma']['restore']['file']
  restore = true if ::File.exist?(restorefile)
end

if upgrade
  log "UPGRADE #{currentversion} to #{upgradeversion}" do
    only_if { upgradeversion.to_i > currentversion.to_i }
  end
  # if the upgrade file is not there download it
  if upgradeurl
    remote_file upgradefile do
      source upgradeurl
      not_if { ::File.exist?(upgradefile) }
    end
  end
  # upgrade
  execute 'chef-automate upgrade run' do
    command "#{chefautomate} upgrade run --airgap-bundle #{upgradefile}"
    cwd fcp
    only_if { upgradeversion.to_i > currentversion.to_i }
  end

elsif restore
  restoredir = fcp + '/a2restore'
  directory restoredir
  log "RESTORE #{restorefile}" do
    not_if { File.exist?(restoredir + '/backup-result.json') }
  end
  # unpack backup tarball if previous backup JSON doesn't exist
  execute "tar -xzf #{restorefile}" do
    command "tar -C #{restoredir} -xzf #{restorefile}"
    action :run
    not_if { File.exist?(restoredir + '/backup-result.json') }
  end
  ruby_block 'chef-automate restore' do
    block do
      backup = shell_out("ls -1 #{restoredir} | head -1").stdout.strip
      puts "\nRestoring: #{backup}"
      shell_out!("#{chefautomate} backup restore --skip-preflight --airgap-bundle #{installfile} -b #{restoredir} #{backup}")
    end
    action :nothing
    subscribes :run, "execute[tar -xzf #{restorefile}]", :immediately
  end

else
  log "INSTALL #{installfile}" do
    not_if { installed }
  end
  # if the install file is not there download it
  if installurl
    remote_file installfile do
      source installurl
      not_if { installed || ::File.exist?(installfile) }
    end
  end
  # create default configuration
  execute "#{chefautomate} init-config --upgrade-strategy none" do
    cwd fcp
    not_if { installed || ::File.exist?("#{fcp}/config.toml") }
  end
  # install
  execute 'chef-automate deploy' do
    command "#{chefautomate} deploy config.toml --accept-terms-and-mlsa --skip-preflight --airgap-bundle #{installfile}"
    cwd fcp
    not_if { installed || ::File.exist?("#{fcp}/automate-credentials.toml") }
  end
end
# END OF INSTALL, UPGRADE OR RESTORE?

# TUNE ELASTICSEARCH
include_recipe 'managed_automate::_elasticsearch'

# LICENSING
licensefile = fcp + '/automate.license'

# get the license from a URL
unless node['ma']['license']['url'].nil?
  remote_file licensefile do
    source node['ma']['license']['url']
    mode '400'
  end
end

# or get the license from a string
unless node['ma']['license']['string'].nil?
  file licensefile do
    content node['ma']['license']['string']
    sensitive true
    mode '400'
  end
end

execute 'chef-automate license apply' do
  command "#{chefautomate} license apply #{licensefile}"
  not_if "#{chefautomate} license status | grep '^License ID'"
end

# should we push the contents of automate-credentials.toml into an attribute or
# log if we don't want logins on the box?
# should we push the admin-token for later? ruby-block to an attribute?
