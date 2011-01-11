# uses the cloud_files library from the cloud_files recipe.

module Autodev

class RpmVersion
  include Comparable

	attr_reader :package_name, :version, :release, :revision, :full_rpm_name

	def initialize(rpm_name="")
		@full_rpm_name=rpm_name
		@package_name=parse_package_name(rpm_name)
		@version=parse_version(rpm_name)
		@release=parse_release(rpm_name)
		@revision=parse_revision_or_dts(@release)
	end

	def <=>(other)
		return @package_name <=> other.package_name if ((@package_name <=> other.package_name) != 0)
		return @version <=> other.version if ((@version <=> other.version) != 0)
		return @revision <=> other.revision
		#return @revision <=> other.revision
	end

	def to_s
		@package_name.to_s + "-" + @version.to_s + "-" + @release.to_s
	end

	private
	def parse_package_name(rpm_name)
		rpm_name.sub(/^(.*)-\d\.\d\.?\d?.*/, '\1')
	end

	def parse_version(rpm_name)
		Autodev::VersionNumber.new(rpm_name.sub(/^.*-(\d\.\d\.?\d?).*/, '\1'))
	end

	def parse_release(rpm_name)
		rpm_name.sub(/^.*-\d\.\d\.?\d?-([^\.]*).*/, '\1')
	end

	#last part of the release after the underscore (our convention)
	def parse_revision_or_dts(release)
		release.sub(/.*_(\d+)/, '\1').to_i
	end

end

class VersionNumber
  include Comparable

	attr_reader :major, :minor, :micro

	def initialize(version="")
		arr=version.split(".")
		if arr[0]
			@major=arr[0].to_i
		else
			@major=0
		end
		if arr[1]
			@minor=arr[1].to_i
		else
			@minor=0
		end
		if arr[2]
			@micro=arr[2].to_i
		else
			@micro=0
		end
	end

	def <=>(other)
		return @major <=> other.major if ((@major <=> other.major) != 0)
		return @minor <=> other.minor if ((@minor <=> other.minor) != 0)
		return @micro <=> other.micro
	end

	def to_s
		@major.to_s + "." + @minor.to_s + "." + @micro.to_s
	end

end

end

class Chef::Recipe::YumRepo

	# list the most recent build of each RPM in the Cloud files directory
	def self.most_recent_rpms(directory)
		all_rpms=CloudFiles.list_cloud_files(directory).collect {|x| Autodev::RpmVersion.new(x)}
		all_rpms.sort! { |a, b| b <=> a } #sort downcase
		recent={}
		all_rpms.each do |rpm|
			package_name=rpm.package_name
			recent.store(package_name, rpm.full_rpm_name) if not recent.has_key?(package_name)
		end
		recent_rpm_names=recent.values.sort! { |a, b| a <=> b }
		if block_given? then
				recent_rpm_names.each { |r| yield r }
		else
				return recent_rpm_names
		end
	end

end
