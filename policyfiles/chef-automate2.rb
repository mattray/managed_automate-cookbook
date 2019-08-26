name 'chef-automate'

run_list 'managed_automate::default'
named_run_list 'backup', 'managed_automate::default', 'managed_automate::backup'
named_run_list 'full', 'managed_automate::airgap_bundle', 'managed_automate::default', 'managed_automate::backup'

default_source :supermarket

cookbook 'managed_automate', path: '..'

# every 5 minutes for testing
override['ma']['backup']['cron']['minute'] = '*/5'
override['ma']['backup']['cron']['hour'] = '*'
override['ma']['backup']['internal']['dir'] = '/tmp/A2backups'

override['ma']['aib']['dir'] = '/tmp/test'
override['ma']['upgrade']['dir'] = '/tmp/test'

# run default with a file, then uncomment to test upgrade
#override['ma']['aib']['file'] = 'automate-20190207004055.aib'
# override['ma']['upgrade']['version'] = '20190131011635'
# override['ma']['upgrade']['file'] = 'automate-20190131011635.aib'

override['ma']['license']['url'] = 'file://localhost/tmp/test/a2.lic'
