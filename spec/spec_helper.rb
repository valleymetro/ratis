require 'simplecov'
require 'active_support/core_ext'
require 'chronic'
require 'hashdiff'
require 'ratis'
require 'rspec'
require 'vcr'
require 'webmock/rspec'
require 'byebug'

I18n.enforce_available_locales = false

SimpleCov.start

project_root = File.expand_path(File.dirname(__FILE__) + "/..")

require "#{project_root}/lib/ratis.rb"
Dir[("#{project_root}/spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.include RatisHelpers
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

HTTPI.log = false
Savon.configure do |config|
  config.log = false
end

Ratis.configure do |config|
  config.appid      = 'ratis-specs'
  config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-271/soap.cgi'
  config.namespace  = 'PX_WEB'
  config.timeout    = 5
end

VCR.configure do |c|
  c.hook_into :webmock
  c.ignore_hosts 'www.valleymetro.org', 'alerts.valleymetro.org'
  c.configure_rspec_metadata!
  # c.preserve_exact_body_bytes { true }
  c.ignore_localhost                        = true
  c.cassette_library_dir                    = "spec/support/vcr_cassettes"
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options                = { record: :new_episodes, allow_playback_repeats: true, match_requests_on: [:method, :uri, :headers] }
  # c.debug_logger                            = File.open(Rails.root.join('log/vcr.log'), 'w')
end
