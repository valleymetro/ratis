require 'ratis/atis_model'

class AtisStop
  extend AtisModel

  attr_accessor :description, :atisstopid, :latitude, :longitude
  attr_accessor :walkdist, :walkdir, :walkhint
  attr_accessor :stopid, :side, :heading, :stopposition, :routedir
  attr_accessor :area, :stop_seq

  implement_soap_action 'Closeststop', 1.11
  implement_soap_action 'Routestops', 1.0

  def self.closest(conditions)
    latitude = conditions.delete :latitude
    longitude = conditions.delete :longitude
    location_text = conditions.delete :location_text
    num_stops = conditions.delete :num_stops

    raise ArgumentError.new('You must provide a longitude') unless longitude
    raise ArgumentError.new('You must provide a latitude') unless latitude

    response = atis_request 'Closeststop',
      {'Locationlat' => latitude, 'Locationlong' => longitude, 'Locationtext' => location_text, 'Numstops' => num_stops}

    return [] unless response.success?

    stops = response.to_hash[:closeststop_response][:stops][:stop].map do |s|
      next if s[:description].blank?

      stop = AtisStop.new
      stop.walkdist = s[:walkdist]
      stop.description = s[:description]
      stop.stopid = s[:stopid]
      stop.atisstopid = s[:atisstopid]
      stop.latitude = s[:lat]
      stop.longitude = s[:long]
      stop.walkdir = s[:walkdir]
      stop.side = s[:side]
      stop.heading = s[:heading]
      stop.stopposition = s[:stopposition]
      stop.routedir = s[:routedirs][:routedir]
      stop
    end
    stops.compact
  end

  def self.route_stops(conditions)
    route = conditions.delete :route
    direction = conditions.delete(:direction).to_s.upcase
    order = conditions.delete(:order).to_s.upcase

    raise ArgumentError.new('You must provide a route') unless route
    raise ArgumentError.new('You must provide a direction') unless direction

    request_params = {'Route' => route, 'Direction' => direction }
    request_params.merge! order ? { 'Order' => order } : {}
    response = atis_request 'Routestops', request_params

    return [] unless response.success?

    response.to_hash[:routestops_response][:stops][:stop].map do |s|
      stop = AtisStop.new
      stop.description = s[:description]
      stop.area = s[:area]
      stop.atisstopid = s[:atisstopid]
      stop.stop_seq = s[:stopseq]
      stop.latitude, stop.longitude = s[:point].split ','
      stop
    end
  end

end

