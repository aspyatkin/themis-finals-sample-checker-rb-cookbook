id = 'themis-finals-sample-checker-rb'

default[id]['basedir'] = '/var/themis/finals/checker/service1'
default[id]['github_repository'] = 'aspyatkin/themis-finals-sample-checker-rb'
default[id]['revision'] = 'develop'
default[id]['user'] = 'vagrant'
default[id]['group'] = 'vagrant'

default[id]['debug'] = true
default[id]['service_alias'] = 'service1'

default[id]['ruby_version'] = '2.3.1'
default[id]['bundler_version'] = '1.12.5'

default[id]['server']['processes'] = 2
default[id]['server']['port_range_start'] = 10_000

default[id]['queue']['processes'] = 2
default[id]['queue']['redis_db'] = 10
