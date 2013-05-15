module Ratis

  ################################# EXAMPLE ############################################
  #
  # Ratis::RouteStops.all :route => 8, :direction => 'S', :order => 'S'
  #
  ######################################################################################

  class RouteStops

    def self.all(conditions)
      route     = conditions.delete(:route)
      direction = conditions.delete(:direction)

      raise ArgumentError.new('You must provide a route')     unless route
      raise ArgumentError.new('You must provide a direction') unless direction

      direction = direction.to_s.upcase
      order     = conditions.delete(:order).to_s.upcase

      Ratis.all_conditions_used? conditions

      request_params = {'Route' => route, 'Direction' => direction }
      request_params.merge! order ? { 'Order' => order } : {}

      response = Request.get 'Routestops', request_params

      return [] unless response.success?

      response.to_hash[:routestops_response][:stops][:stop].map do |s|
        stop = RouteStops::Stop.new
        stop.description              = s[:description]
        stop.area                     = s[:area]
        stop.atis_stop_id             = s[:atisstopid]
        stop.stop_seq                 = s[:stopseq]
        stop.latitude, stop.longitude = s[:point].split(',')
        stop
      end

    end
  end
end
