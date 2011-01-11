# server options
default[:nfs][:export_options] = "172.19.0/17(rw,no_root_squash)"

# client options
default[:nfs][:mount_point] = "/mnt/share"
default[:nfs][:server_name] = "boot1"

#common
default[:nfs][:export_directory] = "/mnt/share"

# Default iptables rule prefix
default[:nfs][:iptables_rule_prefix] = "-s 172.19.0.0/255.255.128.0 -i tun+"
