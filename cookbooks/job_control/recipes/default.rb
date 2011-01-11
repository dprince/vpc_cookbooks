#
# Cookbook Name:: job_control
# Recipe:: default
#
# Copyright 2010, Rackspace.com
#

include_recipe "apache2"
include_recipe "apache2::mod_ssl"

package "rails-stack" do
  action :install
end

package "job-control" do
  action :install
  version node[:job_control][:version] if node[:job_control][:version]
end

service "httpd" do
  action :nothing
end

service "job_harvester" do
  supports :status => true, :restart => true, :reload => false
  action :nothing
end

template "#{node[:job_control][:home]}/config/environments/production.rb" do
  source "production.rb.erb"
  owner node[:job_control][:user]
  notifies :restart, resources("service[job_harvester]", "service[httpd]")
end

user node[:job_control][:user] do
  comment "Job Control User Account"
  uid "1000"
  home "/home/#{node[:job_control][:user]}"
  shell "/bin/bash"
  not_if "getent passwd #{node[:job_control][:user]} &>/dev/null"
end

execute "chown_dir" do
  cwd node[:job_control][:home]
  user "root"
  command "chown -R '#{node[:job_control][:user]}' '#{node[:job_control][:home]}'"
  notifies :restart, resources("service[job_harvester]", "service[httpd]")
  not_if "ls -l #{node[:job_control][:home]}/Rakefile | awk '{print $3}' | grep -c #{node[:job_control][:user]}"
end

bash "db_create" do
  action :run
  cwd node[:job_control][:home]
  user node[:job_control][:user]
  code <<-EOH
    RAILS_ENV=production rails-stack-ruby /usr/lib/rails-stack-gems/bin/rake db:create
    HOME=\"/home/#{node[:job_control][:user]}\" RAILS_ENV=production rails-stack-ruby /usr/lib/rails-stack-gems/bin/rake db:migrate
  EOH
  not_if { File.exists?("#{node[:job_control][:home]}/db/production.sqlite3") }
  notifies :run, resources("execute[chown_dir]")
end

service "job_harvester" do
  action [ :enable, :start ]
end

web_app "job_control" do
  docroot "#{node[:job_control][:home]}/public"
  template "job_control.conf.erb"
  server_name node[:hostname]
  rails_env "production"
end

include_recipe "iptables"
iptables_rule "job_control_iptables_rules" do
  variables(
    :rule_prefix => node[:job_control][:iptables_rule_prefix]
  )
  source "iptables.erb"
end
