module Ratis

  class Timetable::Trip < Struct.new(:ratis_stop_id, :times, :comment, :sign)
  end

end
