require 'ratis/atis_model'

class AtisWalk
  extend AtisModel

  attr_accessor :legs, :walk_distance, :walk_units, :walk_time

  def self.walk_stop(criteria)
    start_latitude = criteria.delete :start_latitude
    start_longitude = criteria.delete :start_longitude
    end_latitude = criteria.delete :end_latitude
    end_longitude = criteria.delete :end_longitude

    raise ArgumentError.new('You must provide a start_latitude') unless start_latitude
    raise ArgumentError.new('You must provide a start_longitude') unless start_longitude
    raise ArgumentError.new('You must provide an end_latitude') unless end_latitude
    raise ArgumentError.new('You must provide an end_longitude') unless end_longitude

    response = atis_request 'Walkstop', 'Startlat' => start_latitude, 'Startlong' => start_longitude, 'Endlat' => end_latitude, 'Endlong' => end_longitude
    return nil unless response.success?

    response_walk = response[:walkstop_response]

    walk = AtisWalk.new
    walk.legs = response_walk[:walk][:leg].collect {|l| { :description => l } }
    walk.walk_distance = response_walk[:walkinfo][:walkdistance]
    walk.walk_units = response_walk[:walkinfo][:walkunits]
    walk.walk_time = response_walk[:walkinfo][:walktime]
    walk
  end

  def to_hash
    keys = [:legs, :walk_distance, :walk_units, :walk_time]
    Hash[keys.map { |k| [k, send(k)] }]
  end
end
