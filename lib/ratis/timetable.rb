module Ratis

  class Timetable

    attr_accessor :route_short_name, :direction, :service_type, :operator, :effective, :timepoints, :trips

    #Ratis::Timetable.where( :route_short_name => "460", :direction => "E", :service_type => 'W')
    def self.where(conditions)
      short_name   = conditions.delete :route_short_name
      direction    = conditions.delete :direction
      date         = conditions.delete :date
      service_type = conditions.delete :service_type

      raise ArgumentError.new('You must provide a route_short_name') unless short_name
      raise ArgumentError.new('You must provide a direction') unless direction
      raise ArgumentError.new('You must provide either date or service_type') if date.blank? && service_type.blank?

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

      timepoints_array = []

      headway[:timepoints][:stop].each_with_index do |tp, i|
        timepoints_array << Timetable::Stop.new(i, tp[:atisstopid], tp[:stopid], tp[:description], tp[:area])
      end rescue []

      timetable.timepoints = timepoints_array

      trips_array = []

      headway[:times][:trip].each_with_index do |t,i|
        trips_array << Timetable::Trip.new(i, t[:time], t[:comment])
      end rescue []

      timetable.trips            =  trips_array

      timetable
    end



  end

end
