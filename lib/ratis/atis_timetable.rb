require 'ratis/atis_model'

class AtisTimetable
  extend AtisModel

  attr_accessor :route_short_name
  attr_accessor :direction
  attr_accessor :service_type
  attr_accessor :operator
  attr_accessor :effective

  def self.where(criteria)
    short_name   = criteria.delete :route_short_name
    direction    = criteria.delete :direction
    date         = criteria.delete :date
    service_type = criteria.delete :service_type

    raise ArgumentError.new('You must provide a route_short_name') unless short_name
    raise ArgumentError.new('You must provide a direction') unless direction
    raise ArgumentError.new('You must provide either date or service_type') unless date ^ service_type

    response = client.request('Timetable', soap_action: 'PX_WEB#Timetable', xmlns: 'PX_WEB') do
      request_attrs = { 'Route' => short_name, 'Direction' => direction }
      request_attrs.merge! date ? { 'Date' => date } : { 'Servicetype' => service_type }

      soap.body = request_attrs
    end
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

