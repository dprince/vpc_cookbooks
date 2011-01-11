#
# Cookbook Name:: iptables
# Recipe:: openvpn
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

include_recipe "iptables"

iptables_rule "openvpn_iptables_rules" do
  source "openvpn_iptables.erb"
end
