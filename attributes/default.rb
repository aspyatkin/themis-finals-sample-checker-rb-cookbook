id = 'themis-finals-service1-checker'

default[id]['fqdn'] = nil

default[id]['basedir'] = '/var/themis/finals/checker/service1'
default[id]['github_repository'] = 'themis-project/themis-finals-service1-checker'
default[id]['revision'] = 'master'

default[id]['debug'] = false
default[id]['service_alias'] = 'service1'

default[id]['ruby_version'] = '2.4.1'
default[id]['bundler_version'] = '1.15.4'

default[id]['server']['processes'] = 2
default[id]['server']['port_range_start'] = 10_000

default[id]['queue']['processes'] = 2
default[id]['queue']['redis_db'] = 10

default[id]['autostart'] = false
