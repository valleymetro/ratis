# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'ratis/version'

Gem::Specification.new do |s|
  s.name             = 'ratis'
  s.version          = Ratis.version
  s.platform         = Gem::Platform::RUBY
  s.summary          = 'A Ruby wrapper around the ATIS SOAP Interface'
  s.authors          = ['Velocity Labs']
  s.email            = 'irish@velocitylabs.io'
  s.files            = `git ls-files`.split($/)
  s.require_paths    = ['lib']
  s.rdoc_options     = ['--charset=UTF-8 --main=README.md']
  s.extra_rdoc_files = ['README.md']

  s.add_dependency 'nesty', '~> 1.0.2'
  s.add_dependency 'savon', '< 2.0'

  s.add_development_dependency 'activesupport',   '< 4.0'
  s.add_development_dependency 'bundler',         '~> 1.5'
  s.add_development_dependency 'chronic',         '~> 0.10'
  s.add_development_dependency 'hashdiff',        '~> 0.1'
  s.add_development_dependency 'rake',            '~> 10.1'
  s.add_development_dependency 'redcarpet',       '~> 2.1'
  s.add_development_dependency 'rspec',           '~> 2.14'
  s.add_development_dependency 'rspec-instafail', '~> 0.2'
  s.add_development_dependency 'byebug',          '~> 2.7'
  s.add_development_dependency 'nokogiri',        '~> 1.6'
  s.add_development_dependency 'simplecov',       '~> 0.8'
  s.add_development_dependency 'vcr',             '~> 2.8'
  s.add_development_dependency 'webmock',         '~> 1.17'
end
