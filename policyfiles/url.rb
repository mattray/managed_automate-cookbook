name 'url'

run_list 'managed-automate2::default'

default_source :supermarket

cookbook 'managed-automate2', path: '..'

override['ma2']['aib']['dir'] = '/tmp/test'
override['ma2']['aib']['url'] = 'file://localhost/tmp/test/automate-20181112131523.aib'
override['ma2']['license']['url'] = 'file://localhost/tmp/test/a2.lic'
