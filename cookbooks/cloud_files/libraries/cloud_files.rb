module CloudFiles

	def self.upload_cloud_file(path, url)

		%x{
		. /usr/local/share/cloud_files/cloud_files.bash
		upload_cloud_file "#{path}" "#{url}"
		}
		return $?.success?

	end

	def self.download_cloud_file(url, path)

		%x{
		. /usr/local/share/cloud_files/cloud_files.bash
		download_cloud_file "#{url}" "#{path}"
		}
		return $?.success?

	end

	def self.list_cloud_files(url)

		out=%x{
		. /usr/local/share/cloud_files/cloud_files.bash
		list_cloud_files "#{url}"
		}
		if $?.success? then
			if block_given? then
				out.split.each {|x| yield x }
			else
				return out.split
			end
		else
			raise "Failed to list cloud files URL: #{url}"
		end

	end

end
