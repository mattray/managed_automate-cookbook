resource_name :automate_airgap_install
provides :automate_airgap_install

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

  unless ::File.exist?(install_file)
    log "INSTALLATION FILE #{install_file} NOT FOUND, INSTALL SKIPPED"
    return
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

  restore_dir = node['ma']['backup']['dir']

  directory restore_dir do
    recursive true
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

  unless ::File.exist?(install_file) && ::File.exist?(restore_file)
    log "INSTALLATION FILE #{install_file} OR RESTORE FILE #{restore_file} NOT FOUND, RESTORE SKIPPED"
    return
  end

  # untar the backup
  execute 'untar restore file' do
    cwd restore_dir
    command "tar -C #{restore_dir} -xzf #{restore_file}"
    action :nothing
  end.run_action(:run) # appears to remove filesystem race conditions

  execute 'chef-automate backup fix-repo-permissions' do
    cwd restore_dir
    command "#{chef_automate} backup fix-repo-permissions #{restore_dir}"
  end

  json = JSON.parse(::File.read(restore_dir + '/backup-result.json'))
  backup_id = json['result']['backup_id']

  execute 'chef-automate backup restore' do
    cwd restore_dir
    timeout 7200 # there appears to be a 2 hour timed out with large restores
    command "#{chef_automate} backup restore --skip-preflight --airgap-bundle #{install_file} #{restore_dir}/#{backup_id}"
  end
end
