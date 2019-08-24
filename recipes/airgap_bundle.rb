#
# Cookbook:: managed-automate2
# Recipe:: airgap_bundle
#

automate_cli 'download the chef-automate CLI' do
  directory node['ma2']['aib']['dir']
  action :download
end

# automate_airgap_bundle NAME do
#   directory # required, probably the NAME
#   filename # optional if we want to rename it something else
#   chef-automate # optional different location of the CLI, will build from automate_cli location
#   action :download
# end



# aibdir = node['ma2']['aib']['dir']
# aibfile = aibdir + '/' + node['ma2']['aib']['file']
# aibchef = aibdir + '/chef-automate'


# # successful execution of this command produces an Airgap Installation Bundle
# execute "#{fcpchef} airgap bundle create" do
#   cwd fcp
#   # it would be nice to have a guard to only run daily
# end

# ruby_block "copy new AIB file to #{aibdir}" do
#   block do
#     previousaib = shell_out("ls -t1 #{aibdir} | grep [0-9].aib$ | head -1").stdout.strip
#     newaib = shell_out("ls -t1 #{fcp} | grep [0-9].aib$ | head -1").stdout.strip
#     puts "\nExisting AIB: #{previousaib}"
#     puts "New AIB: #{newaib}"
#     unless newaib.eql?(previousaib)
#       require 'fileutils'
#       newfile = fcp + '/' + newaib
#       FileUtils.cp(newfile, aibdir)
#       FileUtils.cp(newfile, aibfile)
#     end
#   end
# end
