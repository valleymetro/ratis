require 'savon'

module AtisModel
  def self.extended(base)
    base.extend Savon::Model

    begin
      base.client do
        wsdl.endpoint = 'http://soap.valleymetro.org/cgi-bin-soap-web-new/soap.cgi'
        wsdl.namespace = 'PX_WEB'
        http.proxy = 'http://localhost:8080'
        http.open_timeout = 5
      end
    rescue ArgumentError => e
      raise ArgumentError.new 'Invalid ATIS SOAP server configuration: ' + e.message
    end
  end

  def atis_request(soap_action, params = {})
    client.request soap_action, :soap_action => "PX_WEB##{soap_action}", :xmlns => 'PX_WEB' do
      soap.body = params unless params.blank?
    end
  end

  def valid_latitude?(lat)
    (-90 .. 90).include? lat
  end

  def valid_longitude?(long)
    (-180 .. 180).include? long
  end

  def all_criteria_used?(criteria)
    raise ArgumentError.new("Criteria not used by this class: #{criteria.keys.inspect}") unless criteria.empty?
  end

end

