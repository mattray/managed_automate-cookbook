name 'managed_automate'
maintainer 'Matt Ray'
maintainer_email 'matt@chef.io'
license 'Apache-2.0'
description 'Installs and configures a Chef Automate 2 server'
long_description 'Installs and configures a Chef Automate 2 server'
version '0.10.2'
chef_version '>= 14' if respond_to?(:chef_version)

supports 'redhat'
supports 'centos'

source_url 'https://github.com/mattray/managed-automate2-cookbook'
issues_url 'https://github.com/mattray/managed-automate2-cookbook/issues'
