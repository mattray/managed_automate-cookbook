name 'install'

default_source :supermarket

cookbook 'managed_automate', path: '..'

run_list 'managed_automate::_chef_automate', 'managed_automate::default'

override['ma']['chef-automate'] = '/tmp/chef-automate'
override['ma']['install']['url'] = 'https://mattray.s3-ap-southeast-2.amazonaws.com/automate-20190813170406.aib'
