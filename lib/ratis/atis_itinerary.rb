require 'ratis/atis_model'

class AtisItinerary
  extend AtisModel

  attr_accessor :co2_auto, :co2_transit
  attr_accessor :final_walk_dir, :legs
  attr_accessor :reduced_fare, :regular_fare
  attr_accessor :transit_time

  def self.where(criteria)
    date = criteria.delete :date
    time = criteria.delete :time
    minimize = criteria.delete(:minimize).to_s.upcase

    origin_lat = criteria.delete(:origin_lat).to_f
    origin_long = criteria.delete(:origin_long).to_f
    destination_lat = criteria.delete(:destination_lat).to_f
    destination_long = criteria.delete(:destination_long).to_f

    raise ArgumentError.new('You must provide a date DD/MM/YYYY') unless DateTime.strptime(date, '%d/%m/%Y') rescue false
    raise ArgumentError.new('You must provide a time as 24-hour HHMM') unless DateTime.strptime(time, '%H%M') rescue false
    raise ArgumentError.new('You must provide a criteria of T|X|W to minimize') unless ['T', 'X', 'W'].include? minimize

    raise ArgumentError.new('You must provide an origin latitude') unless valid_latitude? origin_lat
    raise ArgumentError.new('You must provide an origin longitude') unless valid_longitude? origin_long
    raise ArgumentError.new('You must provide an destination latitude') unless valid_latitude? destination_lat
    raise ArgumentError.new('You must provide an destination longitude') unless valid_longitude? destination_long

    all_criteria_used? criteria

    response = atis_request 'Plantrip',
      'Date' => date, 'Time' => time, 'Minimize' => minimize,
      'Originlat' => origin_lat, 'Originlong' => origin_long,
      'Destinationlat' => destination_lat, 'Destinationlong' => destination_long

    return [] unless response.success?

    response.to_array(:plantrip_response, :itin).collect do |itinerary|
      atis_itinerary = AtisItinerary.new
      atis_itinerary.co2_auto = itinerary[:co2auto].to_f
      atis_itinerary.co2_transit = itinerary[:co2transit].to_f
      atis_itinerary.final_walk_dir = itinerary[:finalwalkdir]
      atis_itinerary.reduced_fare = itinerary[:reducedfare].to_f
      atis_itinerary.regular_fare = itinerary[:regularfare].to_f
      atis_itinerary.transit_time = itinerary[:transittime].to_i

      legs = itinerary[:legs][:leg]
      atis_itinerary.legs = legs.kind_of?(Array) ?  legs : [legs].compact

      atis_itinerary
    end

  end

end

