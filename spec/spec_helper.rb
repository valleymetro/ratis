require 'simplecov'
SimpleCov.start

project_root = File.expand_path(File.dirname(__FILE__) + "/..")
$LOAD_PATH << "#{project_root}/lib"

require 'webmock/rspec'
require 'rspec'
require 'active_support/core_ext'
require 'hashdiff'
require 'ratis'

Dir[("#{project_root}/spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.color_enabled = true
  config.include RatisHelpers
end

HTTPI.log = false
Savon.configure do |config|
  config.log = false
end

Ratis.configure do |config|
  config.endpoint = 'http://example.com/soap.cgi'
  config.namespace = 'TEST_NS'
end
