resource_name :automate_airgap_upgrade

property :upgrade_file, String
property :upgrade_url, String
property :chef_automate, String, required: true

action :upgrade do
  chef_automate = new_resource.chef_automate
  upgrade_file = new_resource.upgrade_file
  upgrade_url = new_resource.upgrade_url
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

  unless ::File.exist?(upgrade_file)
    log "UPGRADE FILE #{upgrade_file} NOT FOUND, UPGRADE SKIPPED"
    return
  end

  # check to see what version we're trying to upgrade to
  upgrade_version = shell_out("#{chef_automate} airgap bundle info #{upgrade_file}").stdout.split()[1]

  return unless upgrade_version > current_version

  # upgrade without a current version? Because a nil current_version is < upgrade_version
  log "UPGRADE #{current_version} to #{upgrade_version}"

  execute 'chef-automate upgrade run' do
    command "#{chef_automate} upgrade run --airgap-bundle #{upgrade_file}"
    cwd fcp
  end

  ruby_block "Wait for Automate upgrade completion to #{upgrade_version}" do
    block do
      puts
      wait = 0
      while wait < 10 # upgrade completed or time out after 5 minutes
        if shell_out("#{chef_automate} upgrade status").stdout.match?('upgrading')
          wait += 1
        else
          wait = 10
        end
        shell_out('sleep 30') # needed even after last check
        puts "UPGRADE in progress to #{upgrade_version}:#{wait}/10"
      end
    end
    action :nothing
    subscribes :run, 'execute[chef-automate upgrade run]', :immediately
  end
end
