module Ratis

  class Routepattern

    attr_accessor :route_short_name, :direction, :date, :service_type, :routeid, :stops, :points

    #Ratis::Routepattern.all( :route_short_name => "0", :direction => "N", :date => "01/28/2013", :service_type => 'W', :routeid => "61540")
    def self.all(conditions)
      short_name   = conditions.delete :route_short_name
      direction    = conditions.delete :direction
      date         = conditions.delete :date
      service_type = conditions.delete :service_type
      routeid      = conditions.delete :routeid

      raise ArgumentError.new('You must provide a route_short_name') unless short_name
      raise ArgumentError.new('You must provide a direction') unless direction
      raise ArgumentError.new('You must provide a date') unless date
      raise ArgumentError.new('You must provide a service_type') unless service_type
      raise ArgumentError.new('You must provide a routeid') unless routeid
      Ratis.all_conditions_used? conditions

      request_params = { 'Route' => short_name, 'Direction' => direction, 'Date' => date, 'Servicetype' => service_type, 'Routeid' => routeid }
      
      response = Request.get 'Routepattern', request_params
      return nil unless response.success?
      
      routepattern = Routepattern.new
      
      routepattern.stops = response.to_hash[:routepattern_response][:stops][:stop].map do |s|
        stop = Routepattern::Stop.new
        stop.desc = s[:description]
        stop.area = s[:area]
        stop.atisid = s[:atisstopid]
        stop.stopid = s[:stopid]
        stop.point = s[:point]
        stop.lat, stop.lng = s[:point].split ','
        stop.boardflag = s[:boardflag]
        stop.timepoint = s[:timepoint]
        stop
      end
      
      routepattern.points = response.to_hash[:routepattern_response][:points][:point].map do |p|
        point = Routepattern::Point.new
        point.lat, point.lng = p.split ','
        point
      end

      routepattern
    end

  end

end
