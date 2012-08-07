module Ratis

  class NextBus

    attr_accessor :stops, :runs

    def self.where(conditions)
      stop_id = conditions.delete :stop_id
      app_id = conditions.delete(:app_id) || 'na'

      raise ArgumentError.new('You must provide a stop ID') unless stop_id
      Ratis.all_conditions_used? conditions

      response = Request.get 'Nextbus2', { 'Stopid' => stop_id, 'Appid' => app_id }
      return [] unless response.success?

      next_bus = NextBus.new
      next_bus.stops = response.to_array :nextbus2_response, :stops, :stop
      next_bus.runs = response.to_array :nextbus2_response, :runs, :run

      next_bus
    end

    def first_stop_description
      stops.first ? stops.first[:description] : nil
    end

    def to_hash
      { :stopname => first_stop_description,
        :signs => runs.collect { |run| run[:sign] }.uniq,
        :runs => runs.collect do |run|
          { :time => run[:estimatedtime],
            :sign => run[:sign],
            :adherence => run[:adherence],
            :route => run[:route]
          }
        end
      }
    end

    def to_hash_for_xml
      { :stopname => first_stop_description,
        :runs => runs.collect do |run|
          { :time => run[:estimatedtime],
            :scheduled_time => run[:triptime],
            :sign => run[:sign],
            :adherence => run[:adherence],
            :route => run[:route]
          }
        end
      }
    end
  end

end
