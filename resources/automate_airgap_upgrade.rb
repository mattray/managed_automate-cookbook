resource_name :automate_airgap_upgrade
provides :automate_airgap_upgrade

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

  unless upgrade_version > current_version
    # we need to make sure automate is running at this point
    start_automate(chef_automate, 'UPGRADE:INSTALLED')
    return
  end

  # upgrade without a current version? Because a nil current_version is < upgrade_version
  log "UPGRADE #{current_version} to #{upgrade_version}"

  execute 'chef-automate upgrade run' do
    command "#{chef_automate} upgrade run --airgap-bundle #{upgrade_file}"
    cwd fcp
  end

  # we need to make sure automate is running at this point
  start_automate(chef_automate, 'UPGRADE:UPGRADING')
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
