#
# Cookbook Name:: iptables
# Recipe:: tun0
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

include_recipe "iptables"

iptables_rule "tun0_iptables_rules" do
  source "tun0_iptables.erb"
end
