name 'everything'

default_source :supermarket

cookbook 'managed_automate', path: '..'

run_list 'managed_automate::airgap_bundle', 'managed_automate::restore', 'managed_automate::upgrade', 'managed_automate::backup'

override['ma']['chef-automate'] = '/tmp/test/chef-automate'
override['ma']['aib']['dir'] = '/tmp/test'
override['ma']['install']['url'] = 'file://localhost/tmp/test/automate-20191030224959.aib'
override['ma']['upgrade']['file'] = 'chef-automate.aib'
override['ma']['restore']['file'] = 'a2backup-20181105123003.tgz'
override['ma']['license']['url'] = 'file://localhost/tmp/test/a2.lic'

# every 5 minutes for testing
override['ma']['backup']['cron']['minute'] = '*/5'
override['ma']['backup']['cron']['hour'] = '*'
override['ma']['backup']['internal']['dir'] = '/tmp/A2backups'
