module Ratis

  class Landmark

    attr_accessor :type, :verbose, :location, :locality

    def self.where(conditions)
      app_id  = conditions.delete(:app_id)      || 'WEB'
      type    = conditions.delete(:type).to_s.upcase
      zipcode = conditions.delete(:zipcode)

      raise ArgumentError.new('You must provide a type') if type.blank?
      Ratis.all_conditions_used? conditions

      response = Request.get 'Getlandmarks', {'Appid' => app_id,
                                              'Type' => type,
                                              'Zipcode' => zipcode}
      return [] unless response.success?

      response.to_array(:getlandmarks_response, :landmarks, :landmark).map do |landmark|
        atis_landmark          = Landmark.new
        atis_landmark.type     = landmark[:type]
        atis_landmark.verbose  = landmark[:verbose]
        atis_landmark.location = landmark[:location]
        atis_landmark.locality = landmark[:locality]
        atis_landmark
      end

    end

  end

end
