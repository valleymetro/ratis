require 'ratis/atis_model'

class AtisTimetable
  extend AtisModel

  attr_accessor :route_short_name
  attr_accessor :direction
  attr_accessor :service_type
  attr_accessor :operator
  attr_accessor :effective

  def self.where(conditions)
    short_name   = conditions.delete :route_short_name
    direction    = conditions.delete :direction
    date         = conditions.delete :date
    service_type = conditions.delete :service_type

    raise ArgumentError.new('You must provide a route_short_name') unless short_name
    raise ArgumentError.new('You must provide a direction') unless direction
    raise ArgumentError.new('You must provide either date or service_type') unless date ^ service_type
    all_conditions_used? conditions

    request_params = { 'Route' => short_name, 'Direction' => direction }
    request_params.merge! date ? { 'Date' => date } : { 'Servicetype' => service_type }

    response = atis_request 'Timetable', request_params
    return nil unless response.success?

    headway = response.to_hash[:timetable_response][:headway]
    timetable = AtisTimetable.new
    timetable.route_short_name = headway[:route]
    timetable.direction        = headway[:direction]
    timetable.service_type     = headway[:servicetype]
    timetable.operator         = headway[:operator]
    timetable.effective        = headway[:effective]
    timetable
  end

end

