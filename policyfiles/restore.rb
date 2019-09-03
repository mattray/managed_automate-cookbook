name 'restore'

include_policy 'default', path: './default.lock.json'

run_list 'managed_automate::default'

override['ma']['restore']['url'] = 'file://localhost/tmp/test/automate-backup-20190902064704.tgz'
