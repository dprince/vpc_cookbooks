#
# Cookbook Name:: yum
# Recipe:: repo
#
# Copyright 2010, Rackspace
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"
include_recipe "cloud_files"

package "createrepo" do
  action :install
end

directory node[:yum][:repos_base_directory] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if "test -d #{node[:yum][:repos_base_directory]}"
end

node[:yum][:repos].each do |repo|

	repo_basedir="#{node[:yum][:repos_base_directory]}/#{repo[:name]}"

	directory repo_basedir do
	  owner "root"
	  group "root"
	  mode "0755"
	  action :create
	  not_if "test -d #{repo_basedir}"
	end

	if repo[:cloud_files_directory_list] then
		repo[:cloud_files_directory_list].each do |cf_directory|	

			ruby_block "download_cloud_files" do
			block do

				if not repo[:most_recent_revisions_only] or repo[:most_recent_revisions_only] == "true" then
					YumRepo.most_recent_rpms(cf_directory) do |rpm_name|
						Chef::Log.info("Downloading RPM: #{rpm_name}") if not system("test -f #{repo_basedir}/#{rpm_name}")
						CloudFiles.download_cloud_file("#{cf_directory}/#{rpm_name}", "#{repo_basedir}/#{rpm_name}") if not system("test -f #{repo_basedir}/#{rpm_name}")
					end

				else
					CloudFiles.list_cloud_files(cf_directory) do |rpm_name|
						Chef::Log.info("Downloading RPM: #{rpm_name}") if not system("test -f #{repo_basedir}/#{rpm_name}")

						CloudFiles.download_cloud_file("#{cf_directory}/#{rpm_name}", "#{repo_basedir}/#{rpm_name}") if not system("test -f #{repo_basedir}/#{rpm_name}")
					end
				end

			end
			end

		end
	end

	if repo[:cloud_files_list] then
		repo[:cloud_files_list].each do |cf_file_path|
			download_cloud_file cf_file_path do
				rpm_name=File.basename(cf_file_path)
				location "#{repo_basedir}/#{rpm_name}"
				not_if "test -f #{repo_basedir}/#{rpm_name}"
			end
		end
	end

	if node[:job_control] and node[:job_control][:rpms] then
			node[:job_control][:rpms].each do |cf_file_path|
			download_cloud_file cf_file_path do
					rpm_name=File.basename(cf_file_path)
					location "#{repo_basedir}/#{rpm_name}"
					not_if "test -f #{repo_basedir}/#{rpm_name}"
			end
		end
	end

	bash "createrepo: #{repo[:name]}" do
	  cwd "/tmp"
	  user "root"
	  code <<-EOH
	    cd #{repo_basedir}
	    createrepo .
	  EOH
	end

	# write a file so the yum_client recipes know we are now online
	file "#{repo_basedir}/repo_loaded.txt" do
	  owner "root"
	  group "root"
	  mode "0755"
	  action :create
	end

end

apache_site "000-default" do
  enable false
end

service "apache2" do
  service_name "httpd"
  action :nothing
end

template "#{node[:apache][:dir]}/sites-available/yum_repo.conf" do
  source "yum_repo.conf.erb"
  mode 0644

  variables(
    :server_name => node.fqdn,
    :server_aliases => node.fqdn,
    :docroot => "#{node[:yum][:repos_base_directory]}")
  notifies :restart, resources(:service => "apache2")
end

execute "a2ensite yum_repo.conf" do
  command "/usr/sbin/a2ensite yum_repo.conf"
  notifies :restart, resources(:service => "apache2"), :immediately
  not_if do
    File.symlink?("#{node[:apache][:dir]}/sites-enabled/yum_repo.conf")
  end
  only_if do File.exists?("#{node[:apache][:dir]}/sites-available/yum_repo.conf") end
end
