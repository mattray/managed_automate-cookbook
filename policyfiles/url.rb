name 'url'

run_list 'managed_automate::default'

default_source :supermarket

cookbook 'managed_automate', path: '..'

override['ma']['aib']['dir'] = '/tmp/test'
override['ma']['aib']['url'] = 'file://localhost/tmp/test/automate-20181112131523.aib'
override['ma']['license']['url'] = 'file://localhost/tmp/test/a2.lic'
