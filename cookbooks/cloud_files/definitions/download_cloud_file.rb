define :download_cloud_file do

url=params[:name] # use name param as the URL
location=params[:location] #location

bash "download cloud file: #{url}" do
  cwd "/tmp"
  user "root"
  # download the Yum repo from our Cloud Files account
  code <<-EOH
    . /usr/local/share/cloud_files/cloud_files.bash
    download_cloud_file "#{url}" "#{location}"
  EOH
  not_if { File.exists?(location) }
end

end
