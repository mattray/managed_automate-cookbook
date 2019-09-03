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
      show_progress true
      source install_url
      action :nothing
    end.run_action(:create) # appears to remove filesystem race conditions
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

  restore_dir = fcp + '/automate-restore'

  directory restore_dir do
    action :nothing
  end.run_action(:create) # appears to remove filesystem race conditions

  # if the install file is not there download it
  if restore_url && restore_file.nil?
    restore_file = fcp + '/chef-automate-restore.tgz'
    remote_file restore_file do
      source restore_url
      action :nothing
    end.run_action(:create) # appears to remove filesystem race conditions
  end

  # if the install file is not there download it
  if install_url && install_file.nil?
    install_file = fcp + '/chef-automate.aib'
    remote_file install_file do
      source install_url
      action :nothing
    end.run_action(:create) # appears to remove filesystem race conditions
  end

  # untar the backup
  execute "untar restore file" do
    cwd restore_dir
    command "tar -C #{restore_dir} -xzf #{restore_file}"
    action :nothing
  end.run_action(:run) # appears to remove filesystem race conditions

  #shell_out!("#{chef_automate} backup fix-repo-permissions #{restore_dir}")
  execute "chef-automate backup fix-repo-permissions" do
    cwd restore_dir
    command "#{chef_automate} backup fix-repo-permissions #{restore_dir}"
  end

  # parse the backup-result.json
  json = JSON.parse(::File.read(restore_dir + '/backup-result.json'))
  backup = json['result']['backup_id']

  # shell_out!("#{chef_automate} backup restore --backup-dir #{restore_dir} --skip-preflight --airgap-bundle #{install_file}")
  execute "chef-automate backup restore" do
    cwd restore_dir
    command "#{chef_automate} backup restore --backup-dir #{restore_dir} --skip-preflight --airgap-bundle #{install_file}"
  end
end

action :upgrade do
  chef_automate = new_resource.chef_automate
  upgrade_file = new_resource.install_file
  upgrade_url = new_resource.install_url
  fcp = Chef::Config[:file_cache_path]

  # if the upgrade file is not there download it
  if upgrade_url && upgrade_file.nil?
    upgrade_file = fcp + '/chef-automate-upgrade.aib'
    remote_file upgrade_file do
      show_progress true
      source upgrade_url
      action :nothing
    end.run_action(:create) # appears to remove filesystem race conditions
  end

  # check the version of automate installed
  current_version = shell_out("#{chef_automate} version").stdout.split.last

  # check to see what version we're trying to upgrade to
  upgrade_version = shell_out("#{chef_automate} airgap bundle info #{upgrade_file}").stdout.split()[1]

  return unless upgrade_version > current_version

  # upgrade without a current version? Because a nil current_version is < upgrade_version
  log "UPGRADE #{current_version} to #{upgrade_version}"

  execute 'chef-automate upgrade run' do
    command "#{chef_automate} upgrade run --airgap-bundle #{upgrade_file}"
    cwd fcp
  end
end
