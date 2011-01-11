#
# Cookbook Name:: torque
# Recipe:: server
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

package "torque-server" do
  action :install
end

package "torque-scheduler" do
  action :install
end

package "torque-client" do
  action :install
end

service "pbs_server" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "pbs_sched" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

torque_clients=Set.new
torque_clients.merge(node[:torque][:server][:nodes])

search(:node, "role:torque_client") do |torque_client|
  torque_clients.merge(torque_client.name.sub(/\..*/, ""))
end

template "#{node[:torque][:home]}/server_priv/nodes" do
  source "nodes.erb"
  variables(:nodes => torque_clients.sort)
  notifies :restart, resources(:service => "pbs_server")
end

bash "configure queue" do
  cwd "/tmp"
  user "root"
  code <<-EOH
    qmgr -c "set server scheduling=true"
    qmgr -c "create queue batch queue_type=execution"
    qmgr -c "set queue batch started=true"
    qmgr -c "set queue batch enabled=true"
    qmgr -c "set queue batch resources_default.nodes=1"
    qmgr -c "set queue batch resources_default.walltime=3600"
    qmgr -c "set server default_queue=batch"
    qmgr -c "set server keep_completed=300"
  EOH
  not_if "qmgr -c 'p s' | grep -c keep_completed"
end
