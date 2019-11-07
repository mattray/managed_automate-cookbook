name 'upgrade'

run_list 'managed_automate::install', 'managed_automate::upgrade'

default_source :supermarket

cookbook 'managed_automate', path: '..'

override['ma']['chef-automate'] = '/tmp/test/chef-automate'
override['ma']['install']['url'] = 'file://localhost/tmp/test/automate-20191024135531.aib'
override['ma']['upgrade']['url'] = 'file://localhost/tmp/test/automate-20191030224959.aib'
override['ma']['license']['url'] = 'file://localhost/tmp/test/a2.lic'
