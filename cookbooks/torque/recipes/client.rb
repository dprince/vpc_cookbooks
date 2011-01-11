#
# Cookbook Name:: torque
# Recipe:: client
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

package "torque-mom" do
  action :install
end

file "/var/torque/mom_priv/config" do
  action :touch
  not_if do File.exists?("/var/torque/mom_priv/config") end
end

service "pbs_mom" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

include_recipe "iptables"
iptables_rule "torque_client_iptables_rules" do
  variables(
    :rule_prefix => node[:torque][:iptables_rule_prefix]
  )
  source "client_iptables.erb"
end

template "#{node[:torque][:home]}/server_name" do
  mode 0644
  source "server_name.erb"
  notifies :restart, resources(:service => "pbs_mom")
end
