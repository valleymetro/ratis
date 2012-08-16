module Ratis

  class Point2Point::Stop < Struct.new(:description, :atis_stop_id, :latitude, :longitude,
                          :walk_dist, :walk_dir, :walk_hint,
                          :stop_id, :side, :heading, :stop_position, :route_dir,
                          :area, :stop_seq)

  end

end
