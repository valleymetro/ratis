module Ratis

  class Route

    attr_accessor :short_name, :directions

    def self.all
      response = Request.get 'Allroutes'
      return [] unless response.success?

      routes = response.to_hash[:allroutes_response][:routes].split(/\n/)
      atis_routes = routes.map do |r|
        r.strip!
        next if r.blank?
        r = r.split(/, /)
        Route.new r[0].strip, r[1..-1].map(&:strip)
      end
      atis_routes.compact
    end

    def initialize(short_name, directions)
      self.short_name = short_name
      self.directions = directions
    end

    def timetable(conditions)
      Timetable.where conditions.merge :route_short_name => short_name
    end
  end

end
