require 'ratis/atis_model'

class AtisStop
  extend AtisModel

  attr_accessor :description, :atis_stop_id, :latitude, :longitude
  attr_accessor :walk_dist, :walk_dir, :walk_hint
  attr_accessor :stop_id, :side, :heading, :stop_position, :route_dir
  attr_accessor :area, :stop_seq

  implement_soap_action 'Closeststop', 1.10
  implement_soap_action 'Routestops', 1.0

  def self.closest(conditions)
    latitude = conditions.delete :latitude
    longitude = conditions.delete :longitude
    location_text = conditions.delete :location_text
    num_stops = conditions.delete :num_stops

    raise ArgumentError.new('You must provide a longitude') unless longitude
    raise ArgumentError.new('You must provide a latitude') unless latitude

    all_conditions_used? conditions

    response = atis_request 'Closeststop',
      {'Locationlat' => latitude, 'Locationlong' => longitude, 'Locationtext' => location_text, 'Numstops' => num_stops}

    return [] unless response.success?

    stops = response.to_hash[:closeststop_response][:stops][:stop].map do |s|
      next if s[:description].blank?

      stop = AtisStop.new
      stop.walk_dist = s[:walkdist]
      stop.description = s[:description]
      stop.stop_id = s[:stopid]
      stop.atis_stop_id = s[:atisstopid]
      stop.latitude = s[:lat]
      stop.longitude = s[:long]
      stop.walk_dir = s[:walkdir]
      stop.side = s[:side]
      stop.heading = s[:heading]
      stop.stop_position = s[:stopposition]
      stop.route_dir = s[:routedirs][:routedir]
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

    all_conditions_used? conditions

    request_params = {'Route' => route, 'Direction' => direction }
    request_params.merge! order ? { 'Order' => order } : {}
    response = atis_request 'Routestops', request_params

    return [] unless response.success?

    response.to_hash[:routestops_response][:stops][:stop].map do |s|
      stop = AtisStop.new
      stop.description = s[:description]
      stop.area = s[:area]
      stop.atis_stop_id = s[:atisstopid]
      stop.stop_seq = s[:stopseq]
      stop.latitude, stop.longitude = s[:point].split ','
      stop
    end
  end

end

