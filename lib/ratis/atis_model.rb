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

  def implemented_soap_actions
    @implemented_soap_actions ||= Hash.new { |actions, action| actions[action] = [] }
  end

  def implement_soap_action(action, version)
    self.implemented_soap_actions[action] << version
  end

  def atis_request(action, params = {})
    begin
      response = client.request action, :soap_action => "PX_WEB##{action}", :xmlns => 'PX_WEB' do
        soap.body = params unless params.blank?
      end

      version = response.to_hash["#{action.downcase}_response".to_sym][:version]
      raise AtisError.version_mismatch(action, version) unless implemented_soap_actions[action].include? version.to_f

      response
    rescue Errno::ECONNREFUSED => e
      raise Errno::ECONNREFUSED.new 'Refused request to ATIS SOAP server'
    rescue Savon::SOAP::Fault => e
      raise AtisError.new e
    end
  end

  def valid_latitude?(lat)
    (-90 .. 90).include? lat
  end

  def valid_longitude?(long)
    (-180 .. 180).include? long
  end

  def all_conditions_used?(conditions)
    raise ArgumentError.new("Conditions not used by this class: #{conditions.keys.inspect}") unless conditions.empty?
  end

end

