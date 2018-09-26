#
# Cookbook:: wbg_a006a_managed-automate2
# Recipe:: restore
#

aibdir = node['ma2']['aib']['dir']
aibfile = aibdir + '/' + node['ma2']['aib']['file']
aibchef = aibdir + '/chef-automate'

# where we store our backups
backupdir = node['ma2']['backup']['dir']

# where a2 stores its backups
a2backupdir = '/var/opt/chef-automate/backups'

rfile = backupdir + '/' + node['ma2']['restore']['file']

# create parent restore directory if backup present
directory a2backupdir do
  only_if { !rfile.nil? && ::File.exist?(rfile) }
end

# unpack backup tarball if JSON doesn't exist
# (it having been unpacked from a restore
# or created by an earlier backup)

execute "tar -C #{a2backupdir} -xzf #{rfile}" do
  # action :nothing
  # subscribes :run, "directory[#{a2backupdir}]", :immediately
  action :run
  only_if { !rfile.nil? && ::File.exist?(rfile) && !File.exist?(a2backupdir + '/backup-result.json') }
end

execute 'restore automate-2 from backup' do
  # this restore command assumes that there is only one backup in place: the one we just unpacked
  command "#{aibchef} backup restore --skip-preflight --airgap-bundle #{aibfile} `#{aibchef} backup list | tail -1 | awk '{print $1}'`"
  action :nothing
  subscribes :run, "execute[tar -C #{a2backupdir} -xzf #{rfile}]", :immediately
end

execute 'clean up restore data' do
  command "rm -fr #{a2backupdir}/`#{aibchef} backup list | tail -1 | awk '{print $1}'`"
  action :nothing
  subscribes :run, 'execute[restore automate-2 from backup]', :immediately
end
