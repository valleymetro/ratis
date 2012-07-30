# -*- encoding: utf-8 -*-
require File.expand_path("../lib/ratis/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ratis'
  s.version     = Ratis::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'A Ruby wrapper around the ATIS SOAP Interface'
  s.authors     = ['Dave Tapley']
  s.email       = 'dave.tapley@authoritylabs.com'

  s.add_runtime_dependency 'httpclient'
  s.add_runtime_dependency 'savon'

  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'hashdiff'
  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

