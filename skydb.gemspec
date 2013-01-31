# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)

require 'skydb/version'

Gem::Specification.new do |s|
  s.name        = "skydb"
  s.version     = SkyDB::VERSION
  s.authors     = ["Ben Johnson"]
  s.email       = ["benbjohnson@yahoo.com"]
  s.homepage    = "http://github.com/skydb/sky.rb"
  s.summary     = "A Ruby client for the Sky database"
  s.executables = ['sky']

  s.add_dependency('msgpack', '~> 0.4.7')
  s.add_dependency('commander', '~> 4.1.3')
  s.add_dependency('ruby-progressbar', '~> 1.0.2')
  s.add_dependency('chronic', '~> 0.9.0')
  s.add_dependency('treetop', '~> 1.4.12')
  s.add_dependency('yajl-ruby', '~> 1.1.0')
  s.add_dependency('apachelogregex', '~> 0.1.0')
  s.add_dependency('useragent', '~> 0.4.16')

  s.add_development_dependency('rake', '~> 0.9.2.2')
  s.add_development_dependency('minitest', '~> 3.5.0')
  s.add_development_dependency('mocha', '~> 0.12.5')
  s.add_development_dependency('unindentable', '~> 0.1.0')
  s.add_development_dependency('simplecov', '~> 0.7.1')

  s.test_files   = Dir.glob("test/**/*")
  s.files        = Dir.glob("lib/**/*") + %w(README.md)
  s.require_path = 'lib'
end
