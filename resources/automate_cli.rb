resource_name :automate_cli

property :directory, String, name_property: true
property :filename, String, default: 'chef-automate'

action :download do
  destination_dir = new_resource.directory
  destination_filename = new_resource.filename

  fcp = Chef::Config[:file_cache_path]

  # if chef-automate CLI already exists, no-op
  return if ::File.exist?("#{destination_dir}/#{destination_filename}")

  package 'unzip'

  # download, the create will update if changed according to docs
  remote_file "#{fcp}/chef-automate_linux_amd64.zip" do
    source 'https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip'
  end

  # unzip the package
  # https://docs.chef.io/resource_archive_file.html Chef 15 :(
  execute 'unzip -o chef-automate_linux_amd64.zip' do
    cwd fcp
  end

  # copy chef-automate into the destination directory
  execute "cp #{fcp}/chef-automate #{destination_dir}/#{destination_filename}"

  # set execute permissions
  file "#{destination_dir}/#{destination_filename}" do
    mode '0755'
  end
end
