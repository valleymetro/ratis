require 'ratis/atis_model'

class AtisService
  extend AtisModel

  attr_accessor :route, :direction, :service_type, :signage, :route_type

  implement_soap_action 'Point2point', 1.3

  def self.where(conditions)
    origin_lat = conditions.delete(:origin_lat).to_f
    origin_long = conditions.delete(:origin_long).to_f
    destination_lat = conditions.delete(:destination_lat).to_f
    destination_long = conditions.delete(:destination_long).to_f

    date = conditions.delete :date
    start_time = conditions.delete :start_time
    end_time = conditions.delete :end_time

    raise ArgumentError.new('You must provide an origin latitude') unless valid_latitude? origin_lat
    raise ArgumentError.new('You must provide an origin longitude') unless valid_longitude? origin_long
    raise ArgumentError.new('You must provide an destination latitude') unless valid_latitude? destination_lat
    raise ArgumentError.new('You must provide an destination longitude') unless valid_longitude? destination_long

    raise ArgumentError.new('You must provide a date DD/MM/YYYY') unless DateTime.strptime(date, '%d/%m/%Y') rescue false
    raise ArgumentError.new('You must provide a start time as 24-hour HHMM') unless DateTime.strptime(start_time, '%H%M') rescue false
    raise ArgumentError.new('You must provide an end time as 24-hour HHMM') unless DateTime.strptime(end_time, '%H%M') rescue false

    all_conditions_used? conditions

    response = atis_request 'Point2point',
      'Originlat' => origin_lat, 'Originlong' => origin_long,
      'Destinationlat' => destination_lat, 'Destinationlong' => destination_long,
      'Date' => date, 'Starttime' => start_time, 'Endtime' => end_time,
      'Routesonly' => 'Y'

    return [] unless response.success?

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
end
