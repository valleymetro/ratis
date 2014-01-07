module Ratis

  class LandmarkCategory

    attr_accessor :type, :description, :human_type, :human_description

    def initialize(ti)
      @type              = ti[:type]
      @description       = ti[:description]
      @human_type        = type.gsub(/web/i, "")
      @human_description = description.gsub(/web\s*/i, "")
    end

    def self.all
      response = Request.get 'Getcategories'

      return [] unless response.success?

      categories = response.to_array(:getcategories_response, :types, :typeinfo)
      categories.map do |category|
        Ratis::LandmarkCategory.new(category)
      end
    end

    def self.web_categories
      all.select{|cat| cat.type.include?('WEB') }.map do |cat|
        [ cat.human_description, cat.type ]
      end
    end

  end

end
