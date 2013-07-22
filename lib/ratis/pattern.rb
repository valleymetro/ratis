module Ratis
  class Pattern
    attr_accessor :route_short_name, :direction, :date, :service_type, :longest, :routeinfos

    def initialize(options)
      self.routeinfos = options[:routeinfos]
    end

    def self.all(conditions)
      short_name   = conditions.delete :route_short_name
      direction    = conditions.delete :direction
      date         = conditions.delete :date
      service_type = conditions.delete :service_type
      longest      = conditions.delete :longest

      raise ArgumentError.new('You must provide a route_short_name') unless short_name
      raise ArgumentError.new('You must provide a direction') unless direction
      raise ArgumentError.new('You must provide a date') unless date
      raise ArgumentError.new('You must provide a service_type') unless service_type
      raise ArgumentError.new('You must provide a longest') unless longest

      Ratis.all_conditions_used? conditions

      response = Request.get 'Getpatterns',
                            {'Route'       => short_name,
                             'Direction'   => direction,
                             'Date'        => date,
                             'Servicetype' => service_type,
                             'Longest'     => longest }

      return nil unless response.success?

      routeinfos = response.to_array(:getpatterns_response, :routes, :routeinfo).map do |rinfo|
                     info = Pattern::RouteInfo.new
                     info.route     = rinfo[:route]
                     info.headsign  = rinfo[:signage]
                     info.operate   = rinfo[:operator]
                     info.effective = rinfo[:effective]
                     info.routeid   = rinfo[:routeid]
                     info.routetype = rinfo[:routetype]
                     info.tripcount = rinfo[:tripcount]
                     info.school    = rinfo[:school]
                     info
                   end

      Pattern.new(:routeinfos => routeinfos)
    end

  end

end
