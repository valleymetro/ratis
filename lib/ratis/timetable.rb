module Ratis

  class Timetable

    attr_accessor :route_short_name, :direction, :service_type, :operator, :effective, :timepoints, :trips

    def self.where(conditions)
      short_name   = conditions.delete :route_short_name
      direction    = conditions.delete :direction
      date         = conditions.delete :date
      service_type = conditions.delete :service_type

      raise ArgumentError.new('You must provide a route_short_name') unless short_name
      raise ArgumentError.new('You must provide a direction') unless direction
      raise ArgumentError.new('You must provide either date or service_type') unless date ^ service_type
      Ratis.all_conditions_used? conditions

      request_params = { 'Route' => short_name, 'Direction' => direction }
      request_params.merge! date ? { 'Date' => date } : { 'Servicetype' => service_type }

      response = Request.get 'Timetable', request_params
      return nil unless response.success?

      headway = response.to_hash[:timetable_response][:headway]
      timetable = Timetable.new
      timetable.route_short_name = headway[:route]
      timetable.direction        = headway[:direction]
      timetable.service_type     = headway[:servicetype]
      timetable.operator         = headway[:operator]
      timetable.effective        = headway[:effective]

      stop = headway[:timepoints][:stop]
      timetable.timepoints = [ Timetable::Stop.new(stop[:atisstopid], stop[:stopid], stop[:description], stop[:area]) ]

      trip = headway[:times][:trip]
      timetable.trips = [ Timetable::Trip.new(trip[:time], trip[:comment]) ]

      timetable
    end

  end

end
