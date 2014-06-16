module Ratis

  class Walkstop

    attr_accessor :legs, :walk_distance, :walk_units, :walk_time,
                  :start_lat, :start_long, :end_lat, :end_long,
                  :start_text, :end_text, :success

    def initialize(response)
      @success = response.success?
      @legs    = []

      if @success
        walkstop_response = response[:walkstop_response]
        @legs          = response.to_array(:walkstop_response, :walk, :leg)
        @walk_distance = walkstop_response[:walkinfo][:walkdistance]
        @walk_units    = walkstop_response[:walkinfo][:walkunits]
        @walk_time     = walkstop_response[:walkinfo][:walktime]
        @start_text    = walkstop_response[:starttext]
        @end_text      = walkstop_response[:endtext]
      end
    end

    def self.where(conditions)
      start_lat  = conditions.delete :start_lat
      start_long = conditions.delete :start_long
      end_lat    = conditions.delete :end_lat
      end_long   = conditions.delete :end_long

      raise ArgumentError.new('You must provide a start_lat') unless start_lat
      raise ArgumentError.new('You must provide a start_long') unless start_long
      raise ArgumentError.new('You must provide an end_lat') unless end_lat
      raise ArgumentError.new('You must provide an end_long') unless end_long

      Ratis.all_conditions_used? conditions

      response = Request.get 'Walkstop',
                             'Startlat'  => start_lat,
                             'Startlong' => start_long,
                             'Endlat'    => end_lat,
                             'Endlong'   => end_long

      Walkstop.new(response)
    end

    def to_hash
      keys = [:legs, :walk_distance, :walk_units, :walk_time]
      Hash[keys.map { |k| [k, send(k)] }]
    end
  end

end
