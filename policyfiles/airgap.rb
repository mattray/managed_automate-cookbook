name 'airgap'

run_list 'managed_automate::airgap_bundle'

default_source :supermarket

cookbook 'managed_automate', path: '..'

override['ma']['chef-automate'] = '/tmp/test/chef-automate'
override['ma']['aib']['dir'] = '/tmp/test'
