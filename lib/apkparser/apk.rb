# Copyright (C) 2014 Dave Smith
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'zip'
require 'apkparser/apkresources'
require 'apkparser/apkmanifest'

##
# Class to parse an APK's binary XML format back into textual XML
class Apk
  # APK file where parser will search for XML
  attr_reader :current_apk
  # ApkResources instance used to resolve resources in this APK
  attr_reader :apk_resources
  attr_reader :androidmanifest

  ##
  # Create a new ApkXml instance from the specified +apk_file+
  #
  # This opens and parses the contents of the APK's resources.arsc file.
  def initialize(apk_file)
    @current_apk = apk_file
    @valid_apk = true

    begin
      manifest_data = nil
      resource_data = nil
      Zip.warn_invalid_date = false
      Zip::File.foreach(@current_apk) do |f|
        if f.name.match("AndroidManifest.xml")
          manifest_data = f.get_input_stream.read.force_encoding('BINARY')
        end
        if f.name.match(/resources.arsc/)
          resource_data = f.get_input_stream.read.force_encoding('BINARY')
        end
      end

      Zip.warn_invalid_date = false
      @apk_resources = ApkResources.new(@current_apk,resource_data)
      @androidmanifest = ApkManifest.new(@current_apk,manifest_data,@apk_resources)
    rescue
      @valid_apk = false
      puts "error:#{$!} at:#{$@}"
    end
  end #initialize

  def valid_apk?
    return @valid_apk
  end

  def version_code
    unless @androidmanifest.parsed?
      @androidmanifest.parse_xml(true,false)
    end
    return @androidmanifest.version_code
  end

  def version_name
    unless @androidmanifest.parsed?
      @androidmanifest.parse_xml(true,false)
    end
    return @androidmanifest.version_name
  end

  def min_sdk
    unless @androidmanifest.parsed?
      @androidmanifest.parse_xml(true,false)
    end
    return @androidmanifest.min_sdk
  end

  def target_sdk
    unless @androidmanifest.parsed?
      @androidmanifest.parse_xml(true,false)
    end
    return @androidmanifest.target_sdk
  end

  def package_name
    unless @androidmanifest.parsed?
      @androidmanifest.parse_xml(true,false)
    end
    return @androidmanifest.package_name
  end

  def app_name
    unless @androidmanifest.parsed?
      @androidmanifest.parse_xml(true,false)
    end
    return @androidmanifest.app_name
  end

  def app_icon
    ret = nil
    unless @androidmanifest.parsed?
      @androidmanifest.parse_xml(true,false)
    end
    icon_name = nil
    values = @androidmanifest.app_icons.values
    unless values.nil?
      icon_name = values[-1].data
    end
    unless icon_name.nil?
      ret = {filename:nil,ext:nil,data:nil}
      ret[:filename] = icon_name[(icon_name.rindex("/")+1)..icon_name.size]
      ret[:ext] = icon_name[icon_name.rindex(".")..icon_name.size]
      ret[:data] = get_file_data(icon_name)
    end
    return ret
  end

  def get_meta_value(name="PASSPORT_APPID")
    value = nil
    unless @androidmanifest.parsed?
      @androidmanifest.parse_xml(true,false)
    end
    @androidmanifest.metas.each do |meta|
      attrs = meta.attributes
      unless attrs.find{|attr| attr.name == "name" && attr.value=="#{name}"}.nil?
        value = attrs.find{|attr| attr.name == "value"}.value
      end
      unless value.nil?
        break
      end
    end
    if !value.nil? && (value.is_a? String) && value.start_with?("0x")
      value = @apk_resources.get_default_resource_value(value.hex).data
    end
    return value
  end

  def get_file_data(match)
    return nil if match.nil?

    data = nil
    Zip.warn_invalid_date = false
    Zip::File.foreach(@current_apk) do |f|
      if f.name.match(match)
        data = f.get_input_stream.read.force_encoding('BINARY')
      end
    end
    return data
  end
end
