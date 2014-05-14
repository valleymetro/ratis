module Ratis

  class Landmark

    attr_accessor :type, :verbose, :location, :locality

    def initialize(landmark)
      @type     = landmark[:type]
      @verbose  = landmark[:verbose]
      @location = landmark[:location]
      @locality = landmark[:locality]
    end

    def self.where(conditions)
      app_id  = conditions.delete(:app_id) || 'WEB'
      type    = conditions.delete(:type).to_s.upcase
      zipcode = conditions.delete(:zipcode)

      raise ArgumentError.new('You must provide a type') if type.blank?
      Ratis.all_conditions_used? conditions

      response = Request.get 'Getlandmarks', {'Appid'   => app_id,
                                              'Type'    => type,
                                              'Zipcode' => zipcode}

      return [] unless response.success?

      response.to_array(:getlandmarks_response, :landmark).map do |landmark|
        Landmark.new(landmark)
      end

    end

  end

end
