name 'default'

default_source :supermarket

cookbook 'managed_automate', path: '.'

run_list 'managed_automate::default'
named_run_list :airgap, 'managed_automate::airgap_bundle'
named_run_list :backup, 'managed_automate::default', 'managed_automate::backup'
named_run_list :restore, 'managed_automate::restore'
named_run_list :upgrade, 'managed_automate::default', 'managed_automate::upgrade'
named_run_list :everything, 'managed_automate::airgap_bundle', 'managed_automate::restore', 'managed_automate::upgrade', 'managed_automate::backup'

# default
override['ma']['chef-automate'] = '/tmp/test/chef-automate'
override['ma']['install']['file'] = '/tmp/test/automate-20200707173044.aib'
override['ma']['license']['url'] = 'file://localhost/tmp/test/a2.lic'

# airgap
override['ma']['aib']['dir'] = '/tmp/test'

# backups every 5 minutes for testing
override['ma']['backup']['cron']['minute'] = '*/5'
override['ma']['backup']['cron']['hour'] = '*'
override['ma']['backup']['export']['dir'] = '/tmp/test/backups'
