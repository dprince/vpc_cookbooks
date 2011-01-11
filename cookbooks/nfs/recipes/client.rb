#
# Cookbook Name:: nfs
# Recipe:: client
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

package "nfs-utils" do
  action :install
end

directory node[:nfs][:mount_point] do
  owner "root"
  group "root"
  mode "0777"
  action :create
  recursive true
  not_if "test -d #{node[:nfs][:mount_point]}"
end

package "portmap" do
  action :install
end

service "portmap" do
  supports :status => true, :restart => true, :reload => false
  action [ :start, :enable ]
end

# wait up to 10 minutes for the NFS server to come online
bash "wait on NFS server mounts" do
user "root"
  cwd "/tmp"
  code <<-EOH
    TIMEOUT=60
    while [ $TIMEOUT -gt 0 ]; do
        showmount "#{node[:nfs][:server_name]}" >/dev/null 2>&1 && break
        sleep 10
        let TIMEOUT=${TIMEOUT}-1
    done
    if [ $TIMEOUT -eq 0 ]; then
		echo "Unabled to show mounts of the NFS server."
		exit 1
	fi
  EOH
  not_if "df | grep -c '#{node[:nfs][:mount_point]}$'"
end

mount node[:nfs][:mount_point] do
  device "#{node[:nfs][:server_name]}:#{node[:nfs][:export_directory]}"
  fstype "nfs"
  options "rw,bg"
  action [:mount, :enable]
end
