id = 'themis-finals-sample-checker-rb'

default[id]['basedir'] = '/var/themis/finals/checkers/sample-checker-rb'
default[id]['github_repository'] = 'aspyatkin/themis-finals-sample-checker-rb'
default[id]['revision'] = 'develop'
default[id]['user'] = 'vagrant'
default[id]['group'] = 'vagrant'

default[id]['debug'] = true
default[id]['service_alias'] = 'service_1'

default[id]['server']['processes'] = 2
default[id]['server']['port_range_start'] = 10_000

default[id]['queue']['processes'] = 2
default[id]['queue']['redis_db'] = 10
