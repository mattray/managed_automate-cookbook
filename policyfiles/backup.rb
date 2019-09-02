name 'backup'

include_policy 'default', path: './default.lock.json'

run_list 'managed_automate::backup'

# every 5 minutes for testing
override['ma']['backup']['cron']['minute'] = '*/5'
override['ma']['backup']['cron']['hour'] = '*'
override['ma']['backup']['export']['dir'] = '/tmp/test/backups'
