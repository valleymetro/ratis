Gem::Specification.new do |s|
  s.name        = 'ratis'
  s.version     = '2.5.1'
  s.summary     = 'A Ruby wrapper around the ATIS SOAP Interface'
  s.authors     = ['Dave Tapley']
  s.email       = 'dave.tapley@authoritylabs.com'
  s.files       = ['lib/ratis.rb']

  s.add_runtime_dependency 'savon'
  s.add_runtime_dependency 'httpclient'

  s.add_development_dependency 'rspec'
end

