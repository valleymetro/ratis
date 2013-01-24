module Ratis

  class Area

    attr_accessor :area, :description

    def self.all

      response = Request.get 'Getareas'
      return [] unless response.success?

      response.to_array(:getareas_response, :areainfo).map do |areainfo|
        atis_area = Area.new
        atis_area.area = areainfo[:area]
        atis_area.description = areainfo[:description]
        atis_area
      end
    end

  end

end
