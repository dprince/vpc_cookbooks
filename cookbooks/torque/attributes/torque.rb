# attributes for the torque server recipe (default)
default[:torque][:home] = "/var/torque"
default[:torque][:server_name] = "localhost"

# server nodes
default[:torque][:server][:nodes] = []

# attributes for the user recipe
default[:torque][:job_user][:username] = "racker"

# Default iptables rule prefix
default[:torque][:iptables_rule_prefix] = "-s 172.19.0.0/255.255.128.0 -i tun+"
