# encoding: UTF-8
require File.expand_path('../lib/vandrake/version', __FILE__)

Gem::Specification.new do |s|
  s.name                   = 'vandrake'
  s.version                = Vandrake::Version
  s.summary                = ''
  s.require_path           = 'lib'
  s.authors                = ['Adam Borocz']
  s.email                  = ['adam@hipsnip.com']
  s.platform               = Gem::Platform::RUBY
  s.files                  = Dir.glob('lib/**/*.rb')
  s.required_ruby_version  = '>= 1.9.3'
  s.add_dependency 'activesupport', '~> 4.0.0'
end