#
# Cookbook Name:: cloud_files
# Recipe:: default
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

package "curl" do
  action :install
end

directory "/usr/local/share/cloud_files/" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if "test -d /usr/local/share/cloud_files/"
end

cookbook_file "/usr/local/share/cloud_files/cloud_files.bash" do
  source "cloud_files.bash"
  mode 0755
  owner "root"
  group "root"
end
