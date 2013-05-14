module Ratis

  class Error < StandardError

    attr_accessor :fault_code, :fault_string

    def initialize(savon_soap_fault = nil)
      return if savon_soap_fault.nil? or savon_soap_fault.blank?
      fault             = savon_soap_fault.to_hash[:fault]
      code              = fault[:faultcode].scan(/\d+/).first
      self.fault_code   = code.to_i if code
      self.fault_string = fault[:faultstring]
    end

    # def self.version_mismatch(method, version)
    #   error = Errors.new
    #   error.fault_string = "Unimplemented SOAP method #{ method } #{ version }"
    #   error
    # end

    def to_s
      fault_string
    end

    def verbose_fault_string
      case fault_string
      when /10222|invalid Stopid/i
        'Invalid STOP ID number. Please enter a valid five digit stop ID number'
      when /20003|20046/
        'No stops were found within the walking distance of the origin you specified'
      when /20004|20047/
        'No stops were found within the walking distance of the destination you specified'
      when /20048/
        'No stops were found within the walking distance of the destination or origin you specified'
      when /20005/
        'There is no service at this stop on the date and time specified'
      when /20006/
        'No services run at the date or time specified for your destination'
      when /20007/
        'No trips were found matching the criteria you specified'
      when /20008/
        'No services run at the date or time specified'
      when /11085/
        'Origin is within trivial distance of the destination'
      when /15034/
        'No runs available for the stop and times provided'
      when /1007|no runs available/i
        'There is no service at this stop on the date and time specified'
      when /15035/
        'The route you specified does not serve this stop at the date and time specified'
      when /invalid Window|15030/i
        'The minimum time range is one hour. Please adjust the start and/or end time and try again.'
      when /invalid Location|20024/i
        'Either the origin or destination could not be recognized by the server'
      when /out of range/i
        'The date you entered was out of range - please choose a valid date'
      else
        'The server could not handle your request at this time. Please try again later'
      end
    end
  end

  module Errors

    class ConfigError < StandardError; end
    class SoapError   < Error; end

  end

end
