resource_name :automate_airgap_install

property :install_file, String
property :install_url, String
property :restore_file, String
property :restore_url, String
property :chef_automate, String, required: true

action :install do
  chef_automate = new_resource.chef_automate
  install_file = new_resource.install_file
  install_url = new_resource.install_url
  fcp = Chef::Config[:file_cache_path]

  # is Automate already installed?
  versions = shell_out("#{chef_automate} version").stdout.split
  return unless versions[5].nil? # already installed, we're done here

  # create default configuration
  execute "#{chef_automate} init-config --upgrade-strategy none" do
    cwd fcp
  end

  # if the install file is not there download it
  if install_url && install_file.nil?
    install_file = fcp + '/chef-automate.aib'
    remote_file install_file do
      source install_url
    end
  end

  # install
  execute 'chef-automate deploy' do
    command "#{chef_automate} deploy config.toml --accept-terms-and-mlsa --skip-preflight --airgap-bundle #{install_file}"
    cwd fcp
  end
end

action :restore do
  chef_automate = new_resource.chef_automate
  install_file = new_resource.install_file
  install_url = new_resource.install_url
  restore_file = new_resource.restore_file
  restore_url = new_resource.restore_url

  fcp = Chef::Config[:file_cache_path]

  # is Automate already installed?
  versions = shell_out("#{chef_automate} version").stdout.split
  return unless versions[5].nil? # already installed, we're done here

  # if the install file is not there download it
  if install_url && install_file.nil?
    install_file = fcp + '/chef-automate.aib'
    remote_file install_file do
      source install_url
    end
  end

  # let's restore
    # if restore_url && restore_file.nil?
    #   restore_file = fcp + '/chef-automate-restore
    #   remote_file restore_file do
    #     source restore_url
    #     not_if { ::File.exist?(install_file) }
    #   end
    # end
    #   restoredir = fcp + '/a2restore'
    #   directory restoredir
    #   log "RESTORE #{restorefile}" do
    #     not_if { File.exist?(restoredir + '/backup-result.json') }
    #   end
    # unpack backup tarball if previous backup JSON doesn't exist
    #   execute "tar -xzf #{restorefile}" do
    #     command "tar -C #{restoredir} -xzf #{restorefile}"
    #     action :run
    #    not_if { File.exist?(restoredir + '/backup-result.json') }
    #   end
    #   ruby_block 'chef-automate restore' do
    #     block do
    #       backup = shell_out("ls -1 #{restoredir} | head -1").stdout.strip
    #       puts "\nRestoring: #{backup}"
    #       shell_out!("#{chef_automate} backup restore --skip-preflight --airgap-bundle #{install_file} -b #{restoredir} #{backup}")
    #     end
    #     action :nothing
    #     subscribes :run, "execute[tar -xzf #{restorefile}]", :immediately
    #   end
end

action :upgrade do
  chef_automate = new_resource.chef_automate
  upgrade_file = new_resource.install_file
  upgrade_url = new_resource.install_url
  # # if we have an upgrade URL or we have an upgrade file and a directory, it's an upgrade
  # if node['ma']['upgrade']['url'] || (node['ma']['upgrade']['file'] && node['ma']['upgrade']['dir'])
  #   upgradeversion = node['ma']['upgrade']['version']
  #   upgradefile = node['ma']['upgrade']['dir'] + '/' + node['ma']['upgrade']['file']
  #   upgradeurl = node['ma']['upgrade']['url']
  #   upgrade = true
  # end
  # if upgrade
  #   log "UPGRADE #{currentversion} to #{upgradeversion}" do
  #     only_if { upgradeversion.to_i > currentversion.to_i }
  #   end
  #   # if the upgrade file is not there download it
  #   if upgradeurl
  #     remote_file upgradefile do
  #       source upgradeurl
  #       not_if { ::File.exist?(upgradefile) }
  #     end
  #   end
  #   # upgrade
  #   execute 'chef-automate upgrade run' do
  #     command "#{chef_automate} upgrade run --airgap-bundle #{upgradefile}"
  #     cwd fcp
  #     only_if { upgradeversion.to_i > currentversion.to_i }
  #   end
end
