require 'httpclient'
require 'savon'

class AtisRoute
  extend Savon::Model

  attr_accessor :short_name
  attr_accessor :directions

  client do
    wsdl.endpoint = 'http://soap.valleymetro.org/cgi-bin-soap-web-new/soap.cgi'
    wsdl.namespace = 'PX_WEB'
    http.proxy = 'http://localhost:8080'
  end

  def self.all
    response = client.request 'Allroutes', soap_action: 'PX_WEB#Allroutes', xmlns: 'PX_WEB'
    return [] unless response.success?

    routes = response.to_hash[:allroutes_response][:routes].split(/\n/)
    atis_routes = routes.map do |r|
      r.strip!
      next if r.blank?
      r = r.split /, /
      AtisRoute.new r[0].strip, r[1..-1].map(&:strip)
    end
    atis_routes.compact!
  end

  def initialize(short_name, directions)
    self.short_name = short_name
    self.directions = directions
  end

  def timetable(criteria)
    AtisTimetable.where criteria.merge route_short_name: short_name
  end

end

