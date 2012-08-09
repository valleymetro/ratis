module Ratis

  class LandmarkCategory

    attr_accessor :type, :description

    def self.all

      response = Request.get 'Getcategories'
      return [] unless response.success?

      response.to_array(:getcategories_response, :types, :typeinfo).map do |typeinfo|
        atis_landmark_category = LandmarkCategory.new
        atis_landmark_category.type = typeinfo[:type]
        atis_landmark_category.description = typeinfo[:description]
        atis_landmark_category
      end
    end

  end

end
