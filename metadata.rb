name 'managed_automate'
maintainer 'Matt Ray'
maintainer_email 'matt@chef.io'
license 'Apache-2.0'
description 'Installs and configures a Chef Automate 2 server'
version '0.13.0'
chef_version '>= 15'

supports 'redhat'
supports 'centos'
supports 'debian'

depends 'toml', '~> 0.3.1'

source_url 'https://github.com/mattray/managed-automate2-cookbook'
issues_url 'https://github.com/mattray/managed-automate2-cookbook/issues'
