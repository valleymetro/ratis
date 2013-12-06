module Ratis

  class LandmarkCategory

    attr_accessor :type, :description, :human_type, :human_description

    def self.all
      response = Request.get 'Getcategories'
      return [] unless response.success?

      response.to_array(:getcategories_response, :types, :typeinfo).map do |ti|
        lc                   = LandmarkCategory.new
        lc.type              = ti[:type]
        lc.description       = ti[:description]
        lc.human_type        = lc.type.gsub(/web/i, "")
        lc.human_description = lc.description.gsub(/web\s*/i, "")
        lc
      end
    end

    def self.web_categories
      all.select{|cat| cat.type.include?('WEB') }.map do |cat|
        [ cat.human_description, cat.type ]
      end
    end

  end

end
