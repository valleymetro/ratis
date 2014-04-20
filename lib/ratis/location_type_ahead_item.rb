module Ratis

  class LocationTypeAheadItem

    attr_accessor :name, :area, :areacode, :postcode, :type

    def initialize(params)
      @name     = params[:name]
      @area     = params[:area]
      @areacode = params[:areacode]
      @postcode = params[:postcode]
      @type     = params[:type]
    end

  end
end