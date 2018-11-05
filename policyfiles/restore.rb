name 'restore'

run_list 'managed-automate2::default'

default_source :supermarket

cookbook 'managed-automate2', path: '..'

override['ma2']['aib']['dir'] = '/tmp/test'
override['ma2']['aib']['url'] = 'file://localhost/tmp/test/automate-20181020020209.aib'
override['ma2']['license']['url'] = 'file://localhost/tmp/test/a2.lic'

override['ma2']['restore']['dir'] = '/tmp/test'
override['ma2']['restore']['file'] = 'a2backup-20181105123003.tgz'
