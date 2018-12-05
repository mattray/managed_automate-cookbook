#
# Cookbook:: managed-automate2
# Attributes:: default
#
# Copyright:: 2018, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# airgap_bundle recipe
# set location to copy the airgap installation bundle and chef-automate command
default['ma2']['aib']['dir'] = Chef::Config[:file_cache_path]
default['ma2']['aib']['file'] = 'chef-automate-airgap.aib'
default['ma2']['aib']['url'] = nil
default['ma2']['upgrade']['dir'] = nil
default['ma2']['upgrade']['file'] = nil
default['ma2']['upgrade']['url'] = nil
default['ma2']['upgrade']['version'] = nil
default['ma2']['restore']['dir'] = nil
default['ma2']['restore']['file'] = nil

# default recipe
# sysctl settings to apply to make the preflight-check pass
default['ma2']['sysctl']['fs.file-max'] = 64000
default['ma2']['sysctl']['vm.max_map_count'] = 262144
default['ma2']['sysctl']['vm.dirty_ratio'] = 15
default['ma2']['sysctl']['vm.dirty_background_ratio'] = 35
default['ma2']['sysctl']['vm.dirty_expire_centisecs'] = 20000

default['ma2']['license']['string'] = nil
default['ma2']['license']['url'] = nil

# backup recipe
# schedule via cron
# where A2 stores internal backups
default['ma2']['backup']['internal']['dir'] = '/var/opt/chef-automate/backups'
# where we want to write the backups to for
default['ma2']['backup']['external']['dir'] = '/tmp/backups'
default['ma2']['backup']['prefix'] = 'a2backup-'
# cron settings for scheduling backups
default['ma2']['backup']['cron']['minute'] = '30'
default['ma2']['backup']['cron']['hour'] = '2'
default['ma2']['backup']['cron']['day'] = '*'
