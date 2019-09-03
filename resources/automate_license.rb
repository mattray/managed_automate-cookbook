resource_name :automate_license

property :file, String
property :string, String
property :url, String
property :chef_automate, String, required: true

action :apply do
  license_file = new_resource.file
  license_url = new_resource.url
  license_string = new_resource.string
  chef_automate = new_resource.chef_automate
  fcp = Chef::Config[:file_cache_path]

  status = shell_out("#{chef_automate} license status").stdout

  return if status.include?('License ID')

  if license_file.nil?
    license_file = fcp + '/chef-automate.license' if license_file.nil?
    if license_string
      # write out license file from the string
      file license_file do
        content license_string
        sensitive true
        mode '400'
      end
    elsif license_url
      # download the license
      remote_file license_file do
        source license_url
        sensitive true
        mode '400'
      end
    else
      raise "You must provide a 'string', 'url' or 'file' node['ma']['license'] attribute."
    end
  end

  execute 'chef-automate license apply' do
    command "#{chef_automate} license apply #{license_file}"
  end

  # should we push the contents of automate-credentials.toml into an attribute or
  # log if we don't want logins on the box?
  # should we push the admin-token for later? ruby-block to an attribute?
end
