require 'savon'

require 'ratis/config'
require 'ratis/core_ext'
require 'ratis/closest_stop'
require 'ratis/errors'
require 'ratis/itinerary'
require 'ratis/landmark'
require 'ratis/landmark_category'
require 'ratis/location'
require 'ratis/next_bus'
require 'ratis/point_2_point'
require 'ratis/point_2_point/standard_response'
require 'ratis/point_2_point/group'
require 'ratis/point_2_point/trip'
require 'ratis/point_2_point/service'
require 'ratis/point_2_point/stop'
require 'ratis/request'
require 'ratis/route'
require 'ratis/route_stops'
require 'ratis/schedule_nearby'
require 'ratis/timetable'
require 'ratis/walk'

module Ratis

  extend self

  def configure
    yield config
  end

  def config
    @config ||= Config.new
  end

  def valid_latitude?(lat)
    -90.0 <= lat.to_f and lat.to_f <= 90.0
  end

  def valid_longitude?(lon)
    -180.0 <= lon.to_f and lon.to_f <= 180.0
  end

  def all_conditions_used?(conditions)
    raise ArgumentError.new("Conditions not used by this class: #{conditions.keys.inspect}") unless conditions.empty?
  end

end
