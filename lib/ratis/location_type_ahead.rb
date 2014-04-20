module Ratis

  class LocationTypeAhead

    def self.where(conditions={})
      search_text = conditions.delete(:search)
      app_id      = conditions.delete(:app_id) || 'WEB'

      raise ArgumentError.new('You must provide some search text') unless search_text

      Ratis.all_conditions_used? conditions

      response = Request.get 'Locationtypeahead', {'Appid' => app_id,
                                                   'Search' => search_text.downcase}

      return "" unless response.success?

      response_code = response.to_hash[:locationtypeahead_response][:responsecode]
      locations     = response.to_array :locationtypeahead_response, :items, :item

      locations.map do |location_hash|
        Ratis::LocationTypeAheadItem.new(location_hash.merge(responsecode: response_code))
      end
    end

  end
end