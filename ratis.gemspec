# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'ratis/version'

Gem::Specification.new do |s|
  s.name             = 'ratis'
  s.version          = Ratis.version
  s.platform         = Gem::Platform::RUBY
  s.summary          = 'A Ruby wrapper around the ATIS SOAP Interface'
  s.authors          = ['Burst Software']
  s.email            = 'irish@burstdev.com'
  s.files            = Dir.glob("{bin,lib}/**/*") + %w[README.md]
  s.require_paths    = ['lib']
  s.rdoc_options     = ['--charset=UTF-8 --main=README.md']
  s.extra_rdoc_files = ['README.md']

  s.add_dependency 'savon', '<2.0'

  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'rspec', '~> 2.13.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'hashdiff'
  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'ruby-debug'
end
