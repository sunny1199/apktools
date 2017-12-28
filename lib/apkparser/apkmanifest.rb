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

require 'apkparser/apkxml'

##
# Class to parse an APK's binary XML format back into textual XML
class ApkManifest  < ApkXml
  attr_reader :package_name
  attr_reader :app_name
  attr_reader :app_icons
  attr_reader :version_code
  attr_reader :version_name
  attr_reader :min_sdk
  attr_reader :target_sdk
  attr_reader :metas

  def initialize(apk_file,xml_data=nil,apk_resources=nil)
    super
    @parsed = false
  end #initialize

  def parse_xml(pretty = false, resolve_resources = false)
    xml_output = super
    parse_elements()
    @parsed = true
    return xml_output
  end

  def parse_elements()
    @metas = Array.new()
    xml_elements.each do |element|
      if element.name == "manifest"
        attrs = element.attributes
        @version_code = attrs.find{|attr| attr.name == "versionCode"}.value.hex
        @version_name = attrs.find{|attr| attr.name == "versionName"}.value
        @package_name = attrs.find{|attr| attr.name == "package"}.value
      end
      if element.name == "uses-sdk"
        attrs = element.attributes
        @min_sdk = attrs.find{|attr| attr.name == "minSdkVersion"}.value.hex
        @target_sdk = attrs.find{|attr| attr.name == "targetSdkVersion"}.value.hex
      end
      if element.name == "application"
        attrs = element.attributes
        app_label_id = attrs.find{|attr| attr.name == "label"}.value
        app_icon_id = attrs.find{|attr| attr.name == "icon"}.value
        @app_name = @apk_resources.get_default_resource_value(app_label_id).data
        @app_icons = @apk_resources.get_resource_value(app_icon_id)
      end
      if element.name == "meta-data"
        @metas << element
      end
    end
  end

  def parsed?
    return @parsed
  end
end
