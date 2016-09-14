name 'themis-finals-service1-checker'
description 'Installs and configures Themis Finals sample service1 checker'
version '1.3.0'

recipe 'themis-finals-service1-checker', 'Installs and configures Themis Finals sample service1 checker'
depends 'latest-git', '~> 1.1.11'
depends 'git2', '~> 1.0.0'
depends 'rbenv', '1.7.1'
depends 'supervisor', '~> 0.4.12'
depends 'modern_nginx', '~> 1.3.0'
depends 'ssh_known_hosts', '~> 2.0.0'
depends 'ssh-private-keys', '~> 1.0.0'
