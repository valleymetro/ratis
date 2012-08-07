require 'ratis/atis_model'

class AtisLocation
  extend AtisModel

  attr_accessor :name, :area, :response, :areacode, :latitude, :longitude, :landmark_id, :address, :startaddr, :endaddr, :address_string


  def self.where(conditions)
    location = conditions.delete :location
    media = (conditions.delete(:media) || :w).to_s.upcase
    max_answers = conditions.delete(:max_answers) || 20

    raise ArgumentError.new('You must provide a location') unless location
    raise ArgumentError.new('You must provide media of A|W|I') unless ['A','W','I'].include? media
    raise ArgumentError.new('You must provide a numeric max_answers') unless (Integer max_answers rescue false)
    all_conditions_used? conditions

    response = atis_request 'Locate', {'Location' => location, 'Media' => media, 'Maxanswers' => max_answers}
    return [] unless response.success?

    meta = response.to_hash[:locate_response]
    locations = response.to_array :locate_response, :location

    locations.map do |location_hash|
      location = AtisLocation.new
      location.name = location_hash[:name]
      location.area = location_hash[:area]
      location.response = meta[:responsecode]
      location.areacode = location_hash[:areacode]
      location.latitude = location_hash[:latitude]
      location.longitude = location_hash[:longitude]
      location.landmark_id = location_hash[:landmarkid] || 0
      location.address = location_hash[:address] || ''
      location.startaddr = location_hash[:startaddr] || ''
      location.endaddr = location_hash[:endaddr] || ''
      location.address_string = build_address_string location_hash
      location
    end
  end

  def to_a
    [latitude, longitude, name, landmark_id]
  end

  def to_hash
    keys = [:latitude, :longitude, :name, :area, :address, :startaddr, :endaddr, :address_string, :landmark_id]
    Hash[keys.map { |k| [k, send(k)] }]
  end

private
  def self.build_address_string(location_hash)
    address_string = ''
    address = location_hash[:address]
    name = location_hash[:name]
    area = location_hash[:area]

    if !address.blank?
      address_string << "#{address} #{name} (in #{area})"
    else
      startaddr = location_hash[:startaddr]
      if !startaddr.blank?
        endaddr = location_hash[:endaddr]
        address_string << "#{startaddr} - #{endaddr} #{name} (in #{area})"
      else
        address_string << "#{name} (in #{area})"
      end
    end
    return address_string
  end
end

