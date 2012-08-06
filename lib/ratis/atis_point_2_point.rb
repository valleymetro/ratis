require 'ratis/atis_model'

AtisService = Struct.new :route, :direction, :service_type, :signage, :route_type, :exception

AtisSchedule = Struct.new :groups
AtisScheduleGroup = Struct.new :on_stop, :off_stop, :trips
AtisScheduleTrip = Struct.new :on_time, :off_time, :service

class AtisPoint2Point
  extend AtisModel

  implement_soap_action 'Point2point', 1.3

  def self.where(conditions)
    routes_only = conditions.delete(:routes_only)

    origin_lat = conditions.delete(:origin_lat).to_f
    origin_long = conditions.delete(:origin_long).to_f
    destination_lat = conditions.delete(:destination_lat).to_f
    destination_long = conditions.delete(:destination_long).to_f

    date = conditions.delete :date
    start_time = conditions.delete :start_time
    end_time = conditions.delete :end_time

    raise ArgumentError.new("You must specify routes only with true, false, 'y' or 'n'") unless routes_only.y_or_n rescue false

    raise ArgumentError.new('You must provide an origin latitude') unless valid_latitude? origin_lat
    raise ArgumentError.new('You must provide an origin longitude') unless valid_longitude? origin_long
    raise ArgumentError.new('You must provide an destination latitude') unless valid_latitude? destination_lat
    raise ArgumentError.new('You must provide an destination longitude') unless valid_longitude? destination_long

    raise ArgumentError.new('You must provide a date DD/MM/YYYY') unless DateTime.strptime(date, '%d/%m/%Y') rescue false
    raise ArgumentError.new('You must provide a start time as 24-hour HHMM') unless DateTime.strptime(start_time, '%H%M') rescue false
    raise ArgumentError.new('You must provide an end time as 24-hour HHMM') unless DateTime.strptime(end_time, '%H%M') rescue false

    all_conditions_used? conditions

    response = atis_request 'Point2point', 'Routesonly' => routes_only.y_or_n.upcase,
      'Originlat' => origin_lat, 'Originlong' => origin_long,
      'Destinationlat' => destination_lat, 'Destinationlong' => destination_long,
      'Date' => date, 'Starttime' => start_time, 'Endtime' => end_time

    return nil unless response.success?

    return parse_routes_only_yes response if routes_only.y_or_n.downcase == 'y'
    return parse_routes_only_no response if routes_only.y_or_n.downcase == 'n'

    nil
  end

private
  def self.parse_routes_only_yes(response)
    response.to_array(:point2point_response, :routes, :service).collect do |service|
      atis_service = AtisService.new
      atis_service.route = service[:route]
      atis_service.direction = service[:direction]
      atis_service.service_type = service[:servicetype]
      atis_service.signage = service[:signage]
      atis_service.route_type = service[:routetype]
      atis_service
    end
  end

  def self.parse_routes_only_no(response)
    return nil unless response.success?

    atis_schedule = AtisSchedule.new
    atis_schedule.groups = response.to_array(:point2point_response, :groups, :group).collect do |group|
      atis_schedule_group = AtisScheduleGroup.new

      # Point2point 1.3 uses inconsistent tag naming, thus: <onstop> <onwalk...>, but <offstop> <offstopwalk...>
      # this docs says this is fixed in 1.4, so watch out
      atis_schedule_group.on_stop = atis_stop_from_hash 'on', group[:onstop]
      atis_schedule_group.off_stop = atis_stop_from_hash 'offstop', group[:offstop]

      atis_schedule_group.trips = group.to_array(:trips, :trip).collect do |trip|
        atis_trip = AtisScheduleTrip.new
        atis_trip.on_time = trip[:ontime]
        atis_trip.off_time = trip[:offtime]

        atis_trip.service = trip.to_array(:service).collect do |service|
          atis_service = AtisService.new

          atis_service.route = service[:route]
          atis_service.direction = service[:direction]
          atis_service.service_type = service[:servicetype]
          atis_service.signage = service[:signage]
          atis_service.route_type = service[:routetype]
          atis_service.exception = service[:exception]
          atis_service
        end.first

        atis_trip
      end

      atis_schedule_group
    end

    atis_schedule
  end

  def self.atis_stop_from_hash(prefix, stop)
    return nil if stop.blank?

    atis_stop = AtisStop.new
    atis_stop.description = stop[:description]
    atis_stop.atis_stop_id = stop[:atisstopid].to_i
    atis_stop.latitude = stop[:lat].to_f
    atis_stop.longitude = stop[:long].to_f

    # It appears that both *walk and *walkdist are used for the walk distance, covering both here
    atis_stop.walk_dist = (stop["#{prefix}walk".to_sym] || stop["#{prefix}walkdist".to_sym]).to_f
    atis_stop.walk_dir = stop["#{prefix}walkdir".to_sym]
    atis_stop.walk_hint = stop["#{prefix}walkhint".to_sym]
    atis_stop
  end

end

