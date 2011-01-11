#
# Cookbook Name:: iptables
# Recipe:: nat
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

include_recipe "iptables"

template "/etc/iptables.snat" do
	source "nat_iptables.erb"
	mode 0644
end
