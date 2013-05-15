
module Ratis

  class Timetable::Stop < Struct.new(:ratis_stop_id, :atis_stop_id, :stop_id, :description, :area)
  end

end
