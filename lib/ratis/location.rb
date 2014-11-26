module Ratis

  class Location

    attr_accessor :name, :area, :areacode, :region, :zipname, :latitude, :longitude, :address, :landmark_id,
                  :responsecode, :startaddr, :endaddr, :startlatitude, :startlongitude, :endlatitude, :endlongitude

    def initialize(params)
      @name           = params[:name]
      @area           = params[:area]
      @areacode       = params[:areacode]
      @region         = params[:region]
      @zipname        = params[:zipname]
      @latitude       = params[:latitude]
      @longitude      = params[:longitude]
      @address        = params[:address] || ''
      @landmark_id    = params[:landmarkid] || 0
      @responsecode   = params[:responsecode]
      @startaddr      = params[:startaddr]
      @endaddr        = params[:endaddr]
      @startlatitude  = params[:startlatitude]
      @startlongitude = params[:startlongitude]
      @endlatitude    = params[:endlatitude]
      @endlongitude   = params[:endlongitude]
    end

    def self.where(conditions)
      location    = conditions.delete :location
      media       = (conditions.delete(:media)      || 'W').to_s.upcase
      max_answers = conditions.delete(:max_answers) || 20
      area        = conditions.delete(:area)
      region      = conditions.delete(:region)

      raise ArgumentError.new('You must provide a location') unless location
      raise ArgumentError.new('You must provide media of A|W|I') unless ['A','W','I'].include? media
      raise ArgumentError.new('You must provide a numeric max_answers') unless (Integer max_answers rescue false)

      Ratis.all_conditions_used? conditions

      response = Request.get 'Locate', {'Location'   => location,
                                        'Area'       => area,
                                        'Region'     => region,
                                        'Maxanswers' => max_answers,
                                        'Media'      => media }
      return [] unless response.success?

      response_code = response.to_hash[:locate_response][:responsecode]
      locations     = response.to_array :locate_response, :location

      # {:name=>"N 1ST AVE", :area=>"Avondale", :areacode=>"AV", :region=>"1", :zipname=>"85323 - Avondale", :latitude=>"33.436246", :longitude=>"-112.350520", :address=>"101", :landmarkid=>"0"}
      locations.map do |location_hash|
        Ratis::Location.new(location_hash.merge(responsecode: response_code))
      end

    end

    def to_a
      [latitude, longitude, name, landmark_id]
    end

    def to_hash
      keys = [:name, :area, :areacode, :region, :zipname, :latitude, :longitude, :address, :address_string, :landmark_id, :responsecode, :startaddr, :endaddr, :startlatitude, :startlongitude, :endlatitude, :endlongitude]
      Hash[keys.map { |k| [k, send(k)] }]
    end

    def address_string
      full_address
    end

    def full_address
      temp = ""

      if address.present?
        temp << "#{address} #{name} (in #{area})"
      elsif startaddr.present?
        temp << "#{startaddr} - #{endaddr} #{name} (in #{area})"
      else
        temp << "#{name} (in #{area})"
      end

    end
  end

end
