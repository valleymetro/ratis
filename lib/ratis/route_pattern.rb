module Ratis

  class RoutePattern

    attr_accessor :description, :area, :lat, :long, :point, :atisstopid, :stopid 

    def self.where(conditions)

      #just trying to find by date for now. once this works, will add servicetype condition 
      date = conditions.delete :date
      routeid = conditions.delete :routeid
      direction = conditions.delete :direction

      raise ArgumentError.new('You must provide a date') if date.blank?
      raise ArgumentError.new('You must provide a routeid') unless routeid
      raise ArgumentError.new('You must provide a direction') unless direction


      #not sure what below code does
      Ratis.all_conditions_used? conditions

      response = Request.get 'Routepattern', {'Date' => date, 'Routeid' => routeid, 'Direction' => direction} 
      return [] unless response.success?

      response.to_array(:routepattern_response, :stops, :stop).map do |stop|
        atis_stop = RoutePattern.new
        atis_stop.description = stop[:description]
        atis_stop.area = stop[:area]
        atis_stop.lat = stop[:lat]
        atis_stop.long = stop[:long]
        atis_stop.point = stop[:point]
        atis_stop.atisstopid = stop[:atisstopid]
        atis_stop.stopid = stop[:stopid]
        atis_stop
      end

    end

  end

end
