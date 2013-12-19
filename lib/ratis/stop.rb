module Ratis
  class Stop
    attr_accessor :latitude, :longitude, :area, :walk_dir, :stop_position, :description,
                  :route_dirs, :walk_dist, :side, :stop_id, :heading, :atis_stop_id

    alias_method :lat, :latitude
    alias_method :lng, :longitude

    # :description=>"JEFFERSON STREET/1ST AVE LIGHT RAIL STN", :area=>"Phoenix", :stopid=>"10013", :atisstopid=>"10891",
    # :lat=>"33.448188", :long=>"-112.075198", :walkdist=>"0.08", :walkdir=>"S", :stopposition=>"O", :heading=>"NB", :side=>"Far", :routedirs=>{:routedir=>"LTRL-E"}

    def initialize(params)
      @description   = params[:description]
      @area          = params[:area]
      @stop_id       = params[:stopid]
      @atis_stop_id  = params[:atisstopid]
      @latitude      = params[:lat]
      @longitude     = params[:long]
      @walk_dist     = params[:walkdist]
      @walk_dir      = params[:walkdir]
      @stop_position = params[:stopposition]
      @heading       = params[:heading]
      @side          = params[:side]
      @route_dirs    = params[:routedirs]
    end

    def route_dir
      @route_dirs[:routedir]
    end
  end

end
