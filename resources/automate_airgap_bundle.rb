resource_name :automate_airgap_bundle
provides :automate_airgap_bundle

property :directory, String, name_property: true
property :chef_automate, String, required: true
property :filename, String

action :download do
  destination_dir = new_resource.directory
  destination_filename = new_resource.filename

  return if destination_filename && ::File.exist?("#{destination_dir}/#{destination_filename}")

  command = "#{new_resource.chef_automate} airgap bundle create"
  fcp = Chef::Config[:file_cache_path]

  # find the filename from
  # Success: Your Automate Install Bundle has been written to automate-20190813170406.aib.
  airgap_filename = shell_out(command, cwd: fcp).stdout[/automate-\d{14}.aib/]

  destination_filename = airgap_filename unless destination_filename

  execute "cp #{fcp}/#{airgap_filename} #{destination_dir}/#{destination_filename}" do
    not_if { ::File.exist?("#{destination_dir}/#{destination_filename}") }
  end
end
