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
  s.files            = `git ls-files`.split($/)
  s.require_paths    = ['lib']
  s.rdoc_options     = ['--charset=UTF-8 --main=README.md']
  s.extra_rdoc_files = ['README.md']

  s.add_dependency 'savon', '<2.0'

  s.add_development_dependency 'activesupport', '< 4.0'
  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'chronic'
  s.add_development_dependency 'hashdiff'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'redcarpet', '~> 2.1.1'
  s.add_development_dependency 'rspec', '~> 2.14.0'
  s.add_development_dependency 'rspec-instafail'
  s.add_development_dependency 'debugger'
  s.add_development_dependency 'nokogiri', '> 1.6.0'
  # s.add_development_dependency 'simplecov'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
end
