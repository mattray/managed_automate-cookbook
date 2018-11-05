name 'chef-automate2'

run_list 'managed-automate2::default'
named_run_list 'aib', 'managed-automate2::airgap_bundle'
named_run_list 'backup', 'managed-automate2::default', 'managed-automate2::backup'
named_run_list 'full', 'managed-automate2::airgap_bundle', 'managed-automate2::default', 'managed-automate2::backup'

default_source :supermarket

cookbook 'managed-automate2', path: '..'

# every 5 minutes for testing
override['ma2']['backup']['cron']['minute'] = '*/5'
override['ma2']['backup']['cron']['hour'] = '*'
override['ma2']['backup']['internal']['dir'] = '/tmp/A2backups'

override['ma2']['aib']['dir'] = '/tmp/test'
override['ma2']['aib']['file'] = 'automate-20181020020209.aib'
override['ma2']['license']['string'] = 'redactedbutpasteyoursin'
