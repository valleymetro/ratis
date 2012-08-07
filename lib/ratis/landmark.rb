module Ratis

  class Landmark

    attr_accessor :type, :verbose, :location, :locality

    def self.where(conditions)

      type = conditions.delete(:type).to_s.upcase
      raise ArgumentError.new('You must provide a type') if type.blank?
      Ratis.all_conditions_used? conditions

      response = Request.get 'Getlandmarks', {'Type' => type}
      return [] unless response.success?

      response.to_array(:getlandmarks_response, :landmarks, :landmark).collect do |landmark|
        atis_landmark = Landmark.new
        atis_landmark.type = landmark[:type]
        atis_landmark.verbose = landmark[:verbose]
        atis_landmark.location = landmark[:location]
        atis_landmark.locality = landmark[:locality]
        atis_landmark
      end

    end

  end

end
