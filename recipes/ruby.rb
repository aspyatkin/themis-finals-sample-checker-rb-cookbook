id = 'themis-finals-sample-checker-rb'

include_recipe 'rbenv::default'
include_recipe 'rbenv::ruby_build'

ENV['CONFIGURE_OPTS'] = '--disable-install-rdoc'

rbenv_ruby node[id]['ruby_version'] do
  ruby_version node[id]['ruby_version']
  global true
end

rbenv_gem 'bundler' do
  ruby_version node[id]['ruby_version']
  version node[id]['bundler_version']
end
