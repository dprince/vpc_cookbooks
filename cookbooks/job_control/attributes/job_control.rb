set[:job_control][:home]="/var/rackspace-apps/job-control"

set[:job_control][:version]=nil

default[:job_control][:auth_username]="jobcontrol"
default[:job_control][:auth_password]="fixme"

default[:job_control][:user]="bob"

# Default iptables rule prefix
default[:job_control][:iptables_rule_prefix] = "-s 172.19.0.0/255.255.128.0 -i tun+"
