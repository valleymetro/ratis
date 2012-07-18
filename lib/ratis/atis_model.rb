require 'savon'

module AtisModel
  def self.extended(base)
    base.extend Savon::Model

    base.client do
      wsdl.endpoint = 'http://soap.valleymetro.org/cgi-bin-soap-web-new/soap.cgi'
      wsdl.namespace = 'PX_WEB'
      http.proxy = 'http://localhost:8080'
    end
  end

end

