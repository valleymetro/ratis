module Ratis
  class ClosestStop

    def self.where(conditions)
      latitude      = conditions.delete :latitude
      longitude     = conditions.delete :longitude
      location_text = conditions.delete :location_text
      num_stops     = conditions.delete :num_stops

      raise ArgumentError.new('You must provide a longitude') unless longitude
      raise ArgumentError.new('You must provide a latitude')  unless latitude

      Ratis.all_conditions_used? conditions

      response = Request.get 'Closeststop',
                             {'Locationlat'  => latitude,
                              'Locationlong' => longitude,
                              'Locationtext' => location_text,
                              'Numstops'     => num_stops }

      return [] unless response.success?

      stops = response.to_hash[:closeststop_response][:stops][:stop].map do |arr|
                next if arr[:description].blank?

                stop = Ratis::Stop.new
                stop.walk_dist     = arr[:walkdist]
                stop.description   = arr[:description]
                stop.stop_id       = arr[:stopid]
                stop.atis_stop_id  = arr[:atisstopid]
                stop.latitude      = arr[:lat]
                stop.longitude     = arr[:long]
                stop.walk_dir      = arr[:walkdir]
                stop.side          = arr[:side]
                stop.heading       = arr[:heading]
                stop.stop_position = arr[:stopposition]
                stop.route_dirs    = arr[:routedirs]
                stop

              end.compact

    end

  end

end
