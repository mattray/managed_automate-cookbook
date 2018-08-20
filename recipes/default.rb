#
# Cookbook:: managed-automate2
# Recipe:: default
#

# depend on NTP
# sysctl -w vm.max_map_count=262144
# sysctl -w vm.dirty_expire_centisecs=20000
# echo 192.168.33.199 automate-deployment.test | sudo tee -a /etc/hosts

# https://github.com/mtyler/chef-evaluation/blob/master/scripts/setup_automate.sh

# download chef-automate tool
#    curl https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate
# curl -s https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip |gunzip - > chef-automate && chmod +x chef-automate

# Create config
./chef-automate init-config
sudo ./chef-automate init-config

# Edit config and update FQDN to resolvable name
# vi config.toml

# Install all the things!
# ./chef-automate deploy config.toml
#sudo ./chef-automate deploy config.toml --accept-terms-and-mlsa --skip-preflight > ${GUEST_WKDIR}/logs/automate.deploy.log 2>&1

# if [ -f ${GUEST_WKDIR}/automate.license ]; then
#   sudo ./chef-automate license apply $(< ${GUEST_WKDIR}/automate.license) && sudo ./chef-automate license status
# fi
# sudo ./chef-automate admin-token > ${GUEST_WKDIR}/a2-token
