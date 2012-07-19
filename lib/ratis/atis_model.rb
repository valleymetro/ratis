require 'savon'

module AtisModel
  def self.extended(base)
    base.extend Savon::Model

    base.client do
      wsdl.endpoint = 'http://soap.valleymetro.org/cgi-bin-soap-web-new/soap.cgi'
      wsdl.namespace = 'PX_WEB'
      http.proxy = 'http://localhost:8080'
      http.open_timeout = 5
    end
  end

  def atis_request(soap_action, params = {})
    client.request soap_action, soap_action: "PX_WEB##{soap_action}", xmlns: 'PX_WEB' do
      soap.body = params unless params.blank?
    end
  end

end

