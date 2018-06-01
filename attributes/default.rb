id = 'themis-finals-ruby-service-checker'

default[id]['fqdn'] = nil

default[id]['root'] = '/var/themis/finals/checker'
default[id]['github_repository'] = 'themis-project/themis-finals-ruby-service-checker'
default[id]['revision'] = 'master'

default[id]['debug'] = false
default[id]['service_alias'] = 'ruby'

default[id]['server']['processes'] = 2
default[id]['server']['port_range_start'] = 10_000

default[id]['queue']['processes'] = 2
default[id]['queue']['redis_db'] = nil

default[id]['autostart'] = false
