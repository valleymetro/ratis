module Ratis
  class Timetable::Stop < Struct.new(:atis_stop_id, :stop_id, :description, :area)
  end
end