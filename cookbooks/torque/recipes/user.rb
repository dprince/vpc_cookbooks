#
# Cookbook Name:: torque
# Recipe:: user
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

username=node[:torque][:job_user][:username]

# install different SSH keys on clients and servers
key_type="client"
auth_key_type="server"
if node.run_list.include?("recipe[torque::server]") or node.run_list.include?("role[torque_server]") then
	key_type="server"
	auth_key_type="client"
end

user username do
  comment "Torque Job Submission Account"
  uid "1000"
  home "/home/#{username}"
  shell "/bin/bash"
  not_if "getent passwd #{username} &>/dev/null"
end

directory "/home/#{username}/.ssh" do
  owner username
  group username
  mode "0700"
  action :create
  not_if "test -d /home/#{username}/.ssh"
end

cookbook_file "/home/#{username}/.ssh/id_rsa" do
  source "#{key_type}.id_rsa"
  owner username
  group username
  mode "0600"
  action :create
end

cookbook_file "/home/#{username}/.ssh/id_rsa.pub" do
  source "#{key_type}.id_rsa.pub"
  owner username
  group username
  mode "0644"
  action :create
end

cookbook_file "/home/#{username}/.ssh/authorized_keys" do
  source "#{auth_key_type}.id_rsa.pub"
  owner username
  group username
  mode "0600"
  action :create
end

cookbook_file "/home/#{username}/.ssh/config" do
  source "ssh_config"
  owner username
  group username
  mode "0600"
  action :create
end
