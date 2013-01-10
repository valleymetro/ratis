module Ratis

  class RouteStops::Stop < Struct.new(:description, :area, :stop_id, :atis_stop_id, :point, :alpha_seq, :stop_seq, :latitude, :longitude)
  end

end
