# Copyright (C) 2013 Dave Smith
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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "apkparser"
  spec.version       = "0.8.6"
  spec.authors       = ["huangxiaodong"]
  spec.email         = ["sunny_1199@163.com"]

  spec.summary       = "static analysis tool for android apk"
  spec.description   = "static analysis tool for android apk"
  spec.homepage      = "https://passport.shine.cn"
  spec.license       = "MIT"

  spec.executables << 'get_app_version.rb'
  spec.executables << 'read_manifest.rb'

  spec.files = Dir.glob('lib/**/*.rb') +
      Dir.glob('ext/**/*.{c,cpp,cxx,hpp,h,rb}')
  spec.add_runtime_dependency 'rubyzip', '~> 1.2.1'
end
