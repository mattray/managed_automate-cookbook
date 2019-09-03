name 'upgrade'

run_list 'managed_automate::default'

default_source :supermarket

cookbook 'managed_automate', path: '..'

override['ma']['chef-automate'] = '/tmp/test/chef-automate'
override['ma']['install']['url'] = 'file://localhost/tmp/test/automate-20190813170406.aib'
override['ma']['upgrade']['url'] = 'file://localhost/tmp/test/automate-20190820163418.aib'
override['ma']['license']['url'] = 'file://localhost/tmp/test/a2.lic'
