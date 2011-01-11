# repo configs
default[:yum][:repos_base_directory] = "/var/www/repos"

#client configs
default[:yum][:repo] = "cloud_files"
default[:yum][:repo_name] = "Cloud Files Repo"
default[:yum][:repo_url] = "http://localhost"

default[:yum][:gpgcheck] = "0"

#default[:yum][:includepkgs] = ""

# How caches of upstream downloads are handled.
# Defaults to 'all' (packages/metadata).
#default[:yum][:http_caching] = "all"

#Time (in seconds) after which the metadata  will expire.
default[:yum][:metadata_expire] = "1"

# Number of seconds to wait for a connection before timing out.
default[:yum][:timeout] = "60"

default[:yum][:retries] = "10"
