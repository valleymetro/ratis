require 'simplecov'
SimpleCov.start

project_root = File.expand_path(File.dirname(__FILE__) + "/..")
$LOAD_PATH << "#{project_root}/lib"

require 'webmock/rspec'
require 'rspec'
require 'active_support/core_ext'
require 'hashdiff'
require 'ratis'
require 'vcr'

Dir[("#{project_root}/spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.color_enabled = true
  config.include RatisHelpers
  # config.extend  VCR::RSpec::Macros
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

HTTPI.log = false
Savon.configure do |config|
  config.log = false
end

Ratis.configure do |config|
  config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-252/soap.cgi'
  config.namespace  = 'PX_WEB'
  config.timeout    = 5
end

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = "#{project_root}/spec/support/vcr_cassettes"
  c.configure_rspec_metadata!
  c.preserve_exact_body_bytes { true }
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = {
    :re_record_interval => 1.month
  }
end