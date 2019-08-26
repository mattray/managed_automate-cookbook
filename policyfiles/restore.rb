name 'restore'

run_list 'managed_automate::default'

default_source :supermarket

cookbook 'managed_automate', path: '..'

override['ma']['aib']['dir'] = '/tmp/test'
override['ma']['aib']['url'] = 'file://localhost/tmp/test/automate-20181020020209.aib'
override['ma']['license']['url'] = 'file://localhost/tmp/test/a2.lic'

override['ma']['restore']['dir'] = '/tmp/test'
override['ma']['restore']['file'] = 'a2backup-20181105123003.tgz'
