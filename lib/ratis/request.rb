module Ratis

  class Request

    extend Savon::Model

    def initialize(config = nil)
      config = Ratis.config if config.nil?
      raise Errors::ConfigError('It appears that Ratis.configure has not been called or properly setup') unless config.valid?

      self.class.client do
        wsdl.endpoint     = Ratis.config.endpoint
        wsdl.namespace    = Ratis.config.namespace
        http.proxy        = Ratis.config.proxy unless Ratis.config.proxy.blank?
        http.open_timeout = Ratis.config.timeout unless Ratis.config.timeout.blank?
      end
    rescue ArgumentError => e
      raise ArgumentError.new 'Invalid ATIS SOAP server configuration: ' + e.message
    end

    def self.get(action, params = {})
      begin
        raise Errors::ConfigError, 'It appears that Ratis.configure has not been called or properly setup' unless Ratis.config.valid?

        # Merge in the Appid as set in the configuration.
        params.merge!({ 'Appid' => Ratis.config.appid })

        # ClassMethods from Savon::Model
        # Necessary since calling Ratis.configure doesn't allow changing of values set during Savon initialization
        # Savon memoizes the client config
        endpoint(Ratis.config.endpoint)
        namespace(Ratis.config.namespace)

        response = client.request action, :soap_action => "#{Ratis.config.namespace}##{action}", :xmlns => Ratis.config.namespace do
          soap.body = params unless params.blank?
        end

        # version = response.to_hash["#{action.downcase}_response".to_sym][:version]

        response
      rescue Errno::ECONNREFUSED => e
        raise Errors::NetworkError.new 'Refused request to ATIS SOAP server', e
      rescue Savon::SOAP::Fault => e
        raise Errors::SoapError.new e
      rescue Timeout::Error => e
        raise "TIMEOUT!"
      end
    end

  end

end
