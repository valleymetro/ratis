require 'active_support/core_ext'
require 'hashdiff'
require 'rspec'
require 'simplecov'
require 'webmock/rspec'

SimpleCov.start

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end

require 'ratis/config'

Ratis.configure do |config|
  config.endpoint = 'http://example.com/soap.cgi'
  config.namespace = 'TEST_NS'
end

require 'ratis'

project_root = File.expand_path(File.dirname(__FILE__) + "/..")
Dir[("#{project_root}/spec/support/**/*.rb")].each { |f| require f }

include RatisHelpers

