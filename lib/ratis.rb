require 'savon'
require 'ostruct'

require 'ratis/closest_stop'
require 'ratis/config'
require 'ratis/core_ext'
require 'ratis/errors'
require 'ratis/itinerary'
require 'ratis/landmark'
require 'ratis/landmark_category'
require 'ratis/location'
require 'ratis/next_bus'
require 'ratis/next_bus2'
require 'ratis/pattern'
require 'ratis/pattern/routeinfo'
require 'ratis/plantrip'
require 'ratis/point_2_point'
require 'ratis/point_2_point/group'
require 'ratis/point_2_point/routes_only_response'
require 'ratis/point_2_point/service'
require 'ratis/point_2_point/standard_response'
require 'ratis/point_2_point/stop'
require 'ratis/point_2_point/trip'
require 'ratis/request'
require 'ratis/route'
require 'ratis/route_pattern'
require 'ratis/route_pattern/stop'
require 'ratis/route_pattern/point'
require 'ratis/route_stops'
require 'ratis/route_stops/stop'
require 'ratis/schedule_nearby'
require 'ratis/stop'
require 'ratis/timetable'
require 'ratis/timetable/stop'
require 'ratis/timetable/trip'
require 'ratis/walk'
require 'ratis/area'

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

  # null out the config so that it can be rewritten to, then used in new 'get' calls
  def reset
    @config = nil
  end

end
