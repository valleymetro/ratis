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

      stops = response.to_hash[:closeststop_response][:stops][:stop].map do |stop|
                next if stop[:description].blank?

                Ratis::Stop.new(stop)
              end.compact
    end

  end

end
