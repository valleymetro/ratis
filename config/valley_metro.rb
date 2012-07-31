require 'ratis/config'

Ratis.configure do |config|
  config.endpoint = 'http://soap.valleymetro.org/cgi-bin-soap-web-new/soap.cgi'
  config.namespace = 'PX_WEB'
  config.proxy = 'http://localhost:8080'
  config.timeout = 5
end

