require 'active_support/core_ext'
require 'hashdiff'
require 'ratis'
require 'rspec'
require 'simplecov'
require 'webmock/rspec'

SimpleCov.start

project_root = File.expand_path(File.dirname(__FILE__) + "/..")
Dir[("#{project_root}/spec/support/**/*.rb")].each { |f| require f }

include RatisHelpers

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end

