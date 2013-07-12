module Ratis
  class Routes
    def self.all
      response = Request.get 'Allroutes2'

      return [] unless response.success?

      # {:hexcolor=>"0", :route=>"0", :operator=>"AP", :description=>"0 - route", :publicroute=>"0", :hasrealtime=>"Y", :direction=>"*", :operatorname=>"VEOLIA-PHOENIX", :color=>"#000000"}
      routes = {}
      response.to_hash[:allroutes2_response][:routes][:item].each do |item|
        if routes.has_key? item[:route]
          routes[item[:route]] << item
        else
          routes[item[:route]] = [item]
        end
      end

      routes.map do |short_name, _routes|
        directions = _routes.map{|rte| rte[:direction] }.reject{|dir| dir == '*' }
        Route.new(short_name, directions)
      end.compact.sort_by{|rte| rte.short_name }
    end
  end

end
