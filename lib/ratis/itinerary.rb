module Ratis

  class Itinerary

    attr_accessor :co2_auto, :co2_transit, :final_walk_dir, :legs, :reduced_fare, :regular_fare, :transit_time, :trace_info

    def initialize(response)
      @co2_auto       = response[:co2auto].to_f
      @co2_transit    = response[:co2transit].to_f
      @final_walk_dir = response[:finalwalkdir]
      @reduced_fare   = response[:reducedfare].to_f
      @regular_fare   = response[:regularfare].to_f
      @transit_time   = response[:transittime].to_i
      @trace_info     = response[:traceinfo]
      @legs           = response.to_array :legs, :leg
    end

  end

end

