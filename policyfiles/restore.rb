name 'restore'

run_list 'managed_automate::restore'

default_source :supermarket

cookbook 'managed_automate', path: '..'

override['ma']['chef-automate'] = '/tmp/test/chef-automate'
override['ma']['install']['file'] = '/tmp/test/automate-20191024135531.aib'
override['ma']['restore']['url'] = 'file://localhost/tmp/test/automate-backup-20191107102742.tgz'
override['ma']['license']['url'] = 'file://localhost/tmp/test/a2.lic'
