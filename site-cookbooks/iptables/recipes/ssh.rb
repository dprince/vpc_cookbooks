#
# Cookbook Name:: iptables
# Recipe:: ssh
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

include_recipe "iptables"

iptables_rule "ssh_iptables_rule" do
  source "ssh_iptables.erb"
end
