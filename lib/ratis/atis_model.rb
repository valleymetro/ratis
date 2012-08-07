require 'savon'

module AtisModel
  def self.extended(base)
    base.extend Savon::Model

    raise RuntimeError.new 'It appears that Ratis.configure has not been called' unless Ratis.config.valid?

    begin
      base.client do
        wsdl.endpoint = Ratis.config.endpoint
        wsdl.namespace = Ratis.config.namespace
        http.proxy = Ratis.config.proxy unless Ratis.config.proxy.blank?
        http.open_timeout = Ratis.config.timeout unless Ratis.config.timeout.blank?
      end
    rescue ArgumentError => e
      raise ArgumentError.new 'Invalid ATIS SOAP server configuration: ' + e.message
    end
  end

  def atis_request(action, params = {})
    begin
      response = client.request action, :soap_action => "#{Ratis.config.namespace}##{action}", :xmlns => Ratis.config.namespace do
        soap.body = params unless params.blank?
      end

      version = response.to_hash["#{action.downcase}_response".to_sym][:version]
      # raise AtisError.version_mismatch(action, version) unless implemented_soap_actions[action].include? version.to_f

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

