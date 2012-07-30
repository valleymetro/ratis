require 'ratis/atis_model'

class AtisStop
  extend AtisModel

  attr_accessor :walkdist, :description, :stopid, :atisstopid, :latitude, :longitude, :walkdir, :side, :heading, :stopposition, :routedir

  implement_soap_action 'Closeststop', 1.11

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

end

