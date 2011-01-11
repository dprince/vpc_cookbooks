#
# Cookbook Name:: sudo
# Recipe:: default
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

package "sudo" do
  action [ :install ]
end

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
end
