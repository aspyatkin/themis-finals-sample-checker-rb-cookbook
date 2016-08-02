id = 'themis-finals-sample-checker-rb'

include_recipe 'themis-finals::prerequisite_git'
include_recipe 'themis-finals::prerequisite_ruby'
include_recipe 'themis-finals::prerequisite_supervisor'

directory node[id][:basedir] do
  owner node[id][:user]
  group node[id][:group]
  mode 0755
  recursive true
  action :create
end

url_repository = "https://github.com/#{node[id][:github_repository]}"

if node.chef_environment.start_with? 'development'
  ssh_data_bag_item = nil
  begin
    ssh_data_bag_item = data_bag_item('ssh', node.chef_environment)
  rescue
  end

  ssh_key_map = (ssh_data_bag_item.nil?) ? {} : ssh_data_bag_item.to_hash.fetch('keys', {})

  if ssh_key_map.size > 0
    url_repository = "git@github.com:#{node[id][:github_repository]}.git"
  end
end

git2 node[id][:basedir] do
  url url_repository
  branch node[id][:revision]
  user node[id][:user]
  group node[id][:group]
  action :create
end

if node.chef_environment.start_with? 'development'
  git_data_bag_item = nil
  begin
    git_data_bag_item = data_bag_item('git', node.chef_environment)
  rescue
  end

  git_options = (git_data_bag_item.nil?) ? {} : git_data_bag_item.to_hash.fetch('config', {})

  git_options.each do |key, value|
    git_config "git-config #{key} at #{node[id][:basedir]}" do
      key key
      value value
      scope 'local'
      path node[id][:basedir]
      user node[id][:user]
      action :set
    end
  end
end

# rbenv_execute "Install dependencies at #{node[id][:basedir]}" do
#   command 'bundle'
#   ruby_version node['themis-finals'][:ruby][:version]
#   cwd node[id][:basedir]
#   user node[id][:user]
#   group node[id][:group]
# end

execute "Bootstrap checker at #{node[id]['basedir']}" do
  command 'sh script/bootstrap'
  cwd node[id]['basedir']
  user node[id]['user']
  group node[id]['group']
  environment(
    'PATH' => "/usr/bin/env:/opt/rbenv/shims:#{ENV['PATH']}",
  )
  action :run
end

logs_basedir = ::File.join node[id][:basedir], 'logs'

namespace = "#{node['themis-finals'][:supervisor][:namespace]}.checker.#{node[id][:service_alias]}"
# rbenv_root = node[:rbenv][:root_path]

# sentry_data_bag_item = nil
# begin
#   sentry_data_bag_item = data_bag_item('sentry', node.chef_environment)
# rescue
# end

# sentry_dsn = (sentry_data_bag_item.nil?) ? {} : sentry_data_bag_item.to_hash.fetch('dsn', {})

checker_environment = {
  'PATH' => '/usr/bin/env:/opt/rbenv/shims:%(ENV_PATH)s',
  'HOST' => '127.0.0.1',
  'PORT' => '10000',
  'INSTANCE' => '%(process_num)s',
  # 'APP_INSTANCE' => '%(process_num)s',
  'LOG_LEVEL' => node[id][:debug] ? 'DEBUG' : 'INFO',
  'STDOUT_SYNC' => node[id][:debug],
  # 'BEANSTALKD_URI' => "#{node['themis-finals'][:beanstalkd][:listen][:address]}:#{node['themis-finals'][:beanstalkd][:listen][:port]}",
  # 'TUBE_LISTEN' => "#{node['themis-finals'][:beanstalkd][:tube_namespace]}.service.#{node[id][:service_alias]}.listen",
  # 'TUBE_REPORT' => "#{node['themis-finals'][:beanstalkd][:tube_namespace]}.service.#{node[id][:service_alias]}.report"
}

# unless sentry_dsn.fetch(node[id][:service_alias], nil).nil?
#   checker_environment['SENTRY_DSN'] = sentry_dsn.fetch(node[id][:service_alias])
# end

supervisor_service "#{namespace}.server" do
  command 'sh script/server'
  process_name 'server-%(process_num)s'
  numprocs node[id][:server][:processes]
  numprocs_start 0
  priority 300
  autostart false
  autorestart true
  startsecs 1
  startretries 3
  exitcodes [0, 2]
  stopsignal :INT
  stopwaitsecs 10
  stopasgroup true
  killasgroup true
  user node[id][:user]
  redirect_stderr false
  stdout_logfile ::File.join logs_basedir, 'server-%(process_num)s-stdout.log'
  stdout_logfile_maxbytes '10MB'
  stdout_logfile_backups 10
  stdout_capture_maxbytes '0'
  stdout_events_enabled false
  stderr_logfile ::File.join logs_basedir, 'server-%(process_num)s-stderr.log'
  stderr_logfile_maxbytes '10MB'
  stderr_logfile_backups 10
  stderr_capture_maxbytes '0'
  stderr_events_enabled false
  environment checker_environment
  directory node[id][:basedir]
  serverurl 'AUTO'
  action :enable
end

supervisor_service "#{namespace}.queue" do
  command 'sh script/queue'
  process_name 'queue-%(process_num)s'
  numprocs node[id][:queue][:processes]
  numprocs_start 0
  priority 300
  autostart false
  autorestart true
  startsecs 1
  startretries 3
  exitcodes [0, 2]
  stopsignal :INT
  stopwaitsecs 10
  stopasgroup true
  killasgroup true
  user node[id][:user]
  redirect_stderr false
  stdout_logfile ::File.join logs_basedir, 'queue-%(process_num)s-stdout.log'
  stdout_logfile_maxbytes '10MB'
  stdout_logfile_backups 10
  stdout_capture_maxbytes '0'
  stdout_events_enabled false
  stderr_logfile ::File.join logs_basedir, 'queue-%(process_num)s-stderr.log'
  stderr_logfile_maxbytes '10MB'
  stderr_logfile_backups 10
  stderr_capture_maxbytes '0'
  stderr_events_enabled false
  environment checker_environment
  directory node[id][:basedir]
  serverurl 'AUTO'
  action :enable
end

supervisor_group namespace do
  programs [
    "#{namespace}.server",
    "#{namespace}.queue"
  ]
  action :enable
end

template "#{node[:nginx][:dir]}/sites-available/themis-finals-checker-#{node[id][:service_alias]}.conf" do
  source 'nginx.conf.erb'
  mode 0644
  variables(
    server_name: node[id]['fqdn'],
    service_name: node[id][:service_alias],
    logs_basedir: logs_basedir,
    server_processes: node[id][:server][:processes],
    server_port_start: 10_000,
  )
  notifies :reload, 'service[nginx]', :delayed
  action :create
end

nginx_site "themis-finals-checker-#{node[id][:service_alias]}.conf"
