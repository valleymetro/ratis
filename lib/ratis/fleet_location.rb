module Ratis

  class Vehicle
    attr_accessor :route, :direction, :updatetime, :adherance, :adhchange, :vehicle_id, :offroute, :stopped, :reliable, :inservice, :speed, :heading, :route_id

    def initialize(vehicle)
      @route      = vehicle[:route]
      @direction  = vehicle[:direction]
      @updatetime = vehicle[:updatetime]
      @adherance  = vehicle[:adherance]
      @adhchange  = vehicle[:adhchange]
      @vehicle_id = vehicle[:vehicle_id]
      @offroute   = vehicle[:offroute]
      @stopped    = vehicle[:stopped]
      @reliable   = vehicle[:reliable]
      @inservice  = vehicle[:inservice]
      @speed      = vehicle[:speed]
      @heading    = vehicle[:heading]
      @route_id   = vehicle[:route_id]
    end
  end

  #--------------------------------------------

  class FleetLocation

    def self.current(conditions)
      app_id  = conditions.delete(:app_id) || 'WEB'

      response = Request.get 'Fleetlocation', {'Appid' => app_id}

      return [] unless response.success?

      response.to_array(:fleetlocation_response, :vehicles, :vehicle).map do |vehicle|
        Vehicle.new(vehicle)
      end

    end

  end

end
