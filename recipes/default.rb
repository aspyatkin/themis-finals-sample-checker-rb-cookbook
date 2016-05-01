id = 'themis-finals-sample-checker-rb'

include_recipe 'themis-finals::prerequisite_git'
include_recipe 'themis-finals::prerequisite_ruby'

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

rbenv_execute "Install dependencies at #{node[id][:basedir]}" do
  command 'bundle'
  ruby_version node['themis-finals'][:ruby][:version]
  cwd node[id][:basedir]
  user node[id][:user]
  group node[id][:group]
end

god_basedir = ::File.join node['themis-finals'][:basedir], 'god.d'

template "#{god_basedir}/sample-checker-rb.god" do
  source 'checker.god.erb'
  mode 0644
  variables(
    basedir: node[id][:basedir],
    user: node[id][:user],
    group: node[id][:group],
    service_alias: node[id][:service_alias],
    log_level: node[id][:debug] ? 'DEBUG' : 'INFO',
    stdout_sync: node[id][:debug],
    beanstalkd_uri: "#{node['themis-finals'][:beanstalkd][:listen][:address]}:#{node['themis-finals'][:beanstalkd][:listen][:port]}",
    beanstalkd_tube_namespace: node['themis-finals'][:beanstalkd][:tube_namespace],
    processes: node[id][:processes]
  )
  action :create
end
