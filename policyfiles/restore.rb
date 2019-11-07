name 'restore'

include_policy 'default', path: './default.lock.json'

run_list 'managed_automate::restore'

override['ma']['restore']['url'] = 'file://localhost/tmp/test/20191106192629.tar.gz'
