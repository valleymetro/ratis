module Ratis

  class ClosestStop

    def self.where(conditions)
      latitude = conditions.delete :latitude
      longitude = conditions.delete :longitude
      location_text = conditions.delete :location_text
      num_stops = conditions.delete :num_stops

      raise ArgumentError.new('You must provide a longitude') unless longitude
      raise ArgumentError.new('You must provide a latitude') unless latitude

      Ratis.all_conditions_used? conditions

      response = Request.get 'Closeststop',
        {'Locationlat' => latitude, 'Locationlong' => longitude, 'Locationtext' => location_text, 'Numstops' => num_stops}

      return [] unless response.success?

      stops = response.to_hash[:closeststop_response][:stops][:stop].map do |s|
        next if s[:description].blank?

        stop = Stop.new
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

  end

end
