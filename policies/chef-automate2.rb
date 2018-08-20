name 'chef-automate2'

run_list 'managed-automate2::default'
named_run_list 'aib', 'managed-automate2::airgap_bundle'
named_run_list 'full', 'managed-automate2::airgap_bundle', 'managed-automate2::default'

default_source :supermarket

cookbook 'managed-automate2', path: '..'
