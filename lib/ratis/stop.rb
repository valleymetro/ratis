
module Ratis
  class Stop
    attr_accessor :latitude, :longitude, :area, :walk_dir, :stop_position, :description, :route_dirs, :walk_dist, :side, :stop_id, :heading, :atis_stop_id

    alias_method :lat, :latitude
    alias_method :lng, :longitude

    def route_dir
      @route_dirs[:routedir]
    end
  end

end
