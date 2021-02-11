resource_name :automate_airgap_install
provides :automate_airgap_install

property :install_file, String
property :install_url, String
property :restore_file, String
property :restore_url, String
property :restore_path, String, description: 'Path of the backup which should be restored from an existing location on the filesystem.'
property :chef_automate, String, required: true

action :install do
  chef_automate = new_resource.chef_automate
  install_file = new_resource.install_file
  install_url = new_resource.install_url
  fcp = Chef::Config[:file_cache_path]

  # is Automate already installed?
  if ::File.exist?('/bin/chef-automate')
    # we need to make sure automate is running at this point
    start_automate(chef_automate, 'INSTALL:INSTALLED')
    return
  end

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

  start_automate(chef_automate, 'INSTALL:INSTALLING')
end

action :restore do
  chef_automate = new_resource.chef_automate
  install_file = new_resource.install_file
  install_url = new_resource.install_url
  restore_file = new_resource.restore_file
  restore_url = new_resource.restore_url
  restore_path = new_resource.restore_path
  fcp = Chef::Config[:file_cache_path]

  # Has a restore location been passed?
  if restore_file.nil? && restore_url.nil? && restore_path.nil?
    log 'No restore location has been chosen.  Value of restore_file, restore_url or restore_path must be passed.'
    return
  end

  # is Automate already installed?
  if ::File.exist?('/bin/chef-automate')
    # we need to make sure automate is running at this point
    start_automate(chef_automate, 'RESTORE:INSTALLED')
    return
  end

  restore_dir = node['ma']['backup']['dir']

  directory restore_dir do
    recursive true
    action :nothing
  end.run_action(:create) # appears to remove filesystem race conditions

  # If a restore_path was passed attempt to use it.
  if restore_path
    # Attempt to locate the restore_path in the restore_dir else check to see if a full path was passed and found.
    #   Set the restore_location which will be used in the restore command with the result
    restore_location = if ::File.exist?("#{restore_dir}/#{restore_path}")
                         "#{restore_dir}/#{restore_path}"
                       elsif ::File.exist?(restore_path)
                         restore_path
                       else
                         'could-not-find-restore_path-which-was-passed'
                       end
  else
    # If a restore_path was not passed
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

    # Parse the backup_id from results JSON file.
    json = JSON.parse(::File.read(restore_dir + '/backup-result.json'))
    backup_id = json['result']['backup_id']

    # Set the restore_location which will be used in the restore command
    restore_location = "#{restore_dir}/#{backup_id}"
  end

  # Test to make sure that the restore_location which was set is reachable
  unless ::File.exist(restore_location)
    log "Could not find a restore located at the path provided: #{restore_location}"
    return
  end

  execute 'chef-automate backup fix-repo-permissions' do
    command "#{chef_automate} backup fix-repo-permissions #{restore_dir}"
  end

  # assign heap size to 50% of available memory
  total_mem = node['memory']['total'][0..-3].to_i
  half_mem_megabytes = (total_mem / 1024) / 2

  # Do not make your heap size > 32 GB.
  # https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html#compressed_oops
  # "If you want to play it safe, setting the heap to 31gb is likely safe."
  half_mem_megabytes = 32600 if half_mem_megabytes > 32600

  config = {
    'global.v1': { 'fqdn': node['fqdn'] },
    'elasticsearch.v1.sys.runtime': { 'heapsize': "#{half_mem_megabytes}m" },
  }

  restore_patch = restore_dir + '/restore.toml'

  toml_file restore_patch do
    content config
  end

  execute 'chef-automate backup restore' do
    cwd restore_dir
    timeout 7200 # there appears to be a 2 hour timed out with large restores
    command "#{chef_automate} backup restore --skip-preflight --airgap-bundle #{install_file} #{restore_location} --patch-config #{restore_patch}"
  end

  start_automate(chef_automate, 'RESTORE:RESTORING')
end

action_class do
  def start_automate(chef_automate, reason)
    shell_out("#{chef_automate} start")
    ruby_block "Ensure Automate started:#{reason}" do
      block do
        puts
        wait = 0
        while wait < 10
          if shell_out("#{chef_automate} status").stdout.match?('DOWN')
            wait += 1
          else
            wait = 10
          end
          shell_out('sleep 30') # needed even after last check
          puts "START in progress:#{wait}/10"
        end
      end
      action :run
      not_if "#{chef_automate} status"
    end
  end
end
