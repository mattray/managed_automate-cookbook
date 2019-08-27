name 'restore'

include_policy 'default', path: './default.lock.json'

run_list 'managed_automate::default'

override['ma']['restore']['file'] = 'a2backup-20181105123003.tgz'
