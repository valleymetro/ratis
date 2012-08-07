# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ratis/version', __FILE__)

Gem::Specification.new do |s|
  s.name             = 'ratis'
  s.version          = Ratis::VERSION
  s.platform         = Gem::Platform::RUBY
  s.summary          = 'A Ruby wrapper around the ATIS SOAP Interface'
  s.authors          = ['AuthorityLabs']
  s.email            = 'support@authoritylabs.com'
  s.files            = Dir.glob("{bin,lib}/**/*") + %w[README.md]
  s.require_paths    = ['lib']
  s.rdoc_options     = ['--charset=UTF-8 --main=README.md']
  s.extra_rdoc_files = ['README.md']

  s.add_dependency 'savon'

  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'hashdiff'
  s.add_development_dependency 'bundler', '>= 1.0.0'
end
