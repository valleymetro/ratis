module Ratis

  class RoutePattern

    attr_accessor :description, :area, :lat, :long, :point, :atisstopid, :stopid 

    def self.where(conditions)

      date = conditions.delete :date
      servicetype = conditions.delete :servicetype
      routeid = conditions.delete :routeid
      direction = conditions.delete :direction

      raise ArgumentError.new('You must provide either a date or servicetype') if date.blank? && servicetype.blank?
      raise ArgumentError.new('You must provide a routeid') unless routeid
      raise ArgumentError.new('You must provide a direction') unless direction

      Ratis.all_conditions_used? conditions

      request_params = { 'Routeid' => routeid, 'Direction' => direction} 
      request_params.merge! date ? { 'Date' => date } : { 'servicetype' => servicetype } 

      response = Request.get 'Routepattern', request_params 
      return nil unless response.success?

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
