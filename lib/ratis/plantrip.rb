module Ratis

  class Plantrip

    attr_accessor :success, :itineraries, :walkable, :walkadjust, :input

    def initialize(response)
      @success     = response.success?

      @walkable    = response.body[:walkable]
      @walkadjust  = response.body[:walkadjust]
      @input       = response.body[:plantrip_response][:input]

      @itineraries = response.to_array(:plantrip_response, :itin).map do |itinerary|
                                    Itinerary.new(itinerary)
                                  end
    end

    def self.where(conditions)
      minimize                = conditions.delete(:minimize).try(:upcase) || 'T'
      arrdep                  = conditions.delete(:arrdep).try(:upcase)   || "D"
      maxanswers              = conditions.delete(:maxanswers)            || '3'
      xmode                   = conditions.delete(:xmode)                 || 'BCFKLRSTX'
      walkdist                = conditions.delete(:walkdist)              || "0.50"
      origin_lat              = conditions.delete(:origin_lat).to_f
      origin_long             = conditions.delete(:origin_long).to_f
      origin_text             = conditions.delete(:origin_text)
      origin_landmark_id      = conditions.delete(:origin_landmark_id)
      destination_lat         = conditions.delete(:destination_lat).to_f
      destination_long        = conditions.delete(:destination_long).to_f
      destination_text        = conditions.delete(:destination_text)
      destination_landmark_id = conditions.delete(:destination_landmark_id)

      if datetime = conditions.delete(:datetime)
        raise ArgumentError.new('If datetime supplied it should be a Time or DateTime instance, otherwise it defaults to Time.now') unless datetime.is_a?(DateTime) || datetime.is_a?(Time)
      else
        datetime = Time.now
      end

      raise ArgumentError.new('You must provide a date DD/MM/YYYY') unless DateTime.strptime(date, '%d/%m/%Y') rescue false
      raise ArgumentError.new('You must provide a time as 24-hour HHMM') unless DateTime.strptime(time, '%H%M') rescue false
      raise ArgumentError.new('You must provide a conditions of T|X|W to minimize') unless ['T', 'X', 'W'].include? minimize

      raise ArgumentError.new('You must provide an origin latitude') unless Ratis.valid_latitude? origin_lat
      raise ArgumentError.new('You must provide an origin longitude') unless Ratis.valid_longitude? origin_long
      raise ArgumentError.new('You must provide an destination latitude') unless Ratis.valid_latitude? destination_lat
      raise ArgumentError.new('You must provide an destination longitude') unless Ratis.valid_longitude? destination_long

      Ratis.all_conditions_used? conditions

      response = Request.get 'Plantrip', {'Date'                  => datetime.strftime("%m/%d/%Y"),
                                          'Time'                  => datetime.strftime("%H%M"),
                                          'Minimize'              => minimize,
                                          'Arrdep'                => arrdep,
                                          'Maxanswers'            => maxanswers,
                                          'Walkdist'              => walkdist,
                                          'Xmode'                 => xmode,
                                          'Originlat'             => origin_lat,
                                          'Originlong'            => origin_long,
                                          'Origintext'            => origin_text,
                                          'Originlandmarkid'      => origin_landmark_id,
                                          'Destinationlat'        => destination_lat,
                                          'Destinationlong'       => destination_long,
                                          'Destinationtext'       => destination_text,
                                          'Destinationlandmarkid' => destination_landmark_id}

      Plantrip.new(response)
    end

    def success?
      @success
    end
  end

end