#
# Cookbook Name:: nfs
# Recipe:: server
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

package "portmap" do
  action :install
end

package "nfs-utils" do
  action :install
end

directory node[:nfs][:export_directory] do
  owner "root"
  group "root"
  mode "0777"
  action :create
  recursive true
  not_if "test -d #{node[:nfs][:export_directory]}"
end

template "/etc/exports" do
  source "exports.erb"
  mode 0644
end

template "/etc/sysconfig/nfs" do
  source "nfs.erb"
  mode 0644
end

service "portmap" do
  supports :status => true, :restart => true, :reload => false
  action [ :start, :enable ]
end

service "nfs" do
  action [ :enable, :start ]
  subscribes :restart, resources("template[/etc/exports]", "template[/etc/sysconfig/nfs]")
end

include_recipe "iptables"
iptables_rule "nfs_server_iptables_rules" do
  variables(
    :rule_prefix => node[:nfs][:iptables_rule_prefix]
  )
  source "iptables.erb"
end
