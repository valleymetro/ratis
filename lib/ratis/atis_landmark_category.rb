require 'ratis/atis_model'

class AtisLandmarkCategory
  extend AtisModel

  attr_accessor :type, :description

  def self.all

    response = atis_request 'Getcategories'
    return [] unless response.success?

    response.to_array(:getcategories_response, :types, :typeinfo).collect do |typeinfo|
      atis_landmark_category = AtisLandmarkCategory.new
      atis_landmark_category.type = typeinfo[:type]
      atis_landmark_category.description = typeinfo[:description]
      atis_landmark_category
    end
  end

end

