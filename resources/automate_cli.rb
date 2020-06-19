resource_name :automate_cli
provides :automate_cli

property :chef_automate, String

action :download do
  chef_automate = new_resource.chef_automate

  fcp = Chef::Config[:file_cache_path]

  # if chef-automate CLI already exists, no-op
  return if ::File.exist?(chef_automate)

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

  # copy chef-automate to the destination filename
  execute "cp #{fcp}/chef-automate #{chef_automate}"

  # set execute permissions
  file chef_automate do
    mode '0755'
  end
end
