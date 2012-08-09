module Ratis

  class NextBus

    attr_accessor :stops, :runs

    # Initializes a NextBus object with stops and runs.
    # @return     [NextBus]
    #
    # == Parameters:
    #
    # [stops]    <em>Optional</em> - 
    #            An array of stops. Defaults to empty array.
    # [runs]     <em>Optional</em> - 
    #            An array of runs. Defaults to empty array.

    def initialize(_stops = [], _runs = [])
      @stops, @runs = _stops, _runs
    end

    # Returns results of NextBus query containing arrays of stops and runs.
    # @return     [NextBus] containing next buses.
    #
    # == Parameters:
    #
    # Takes hash of conditions
    #
    # [option1]      <b>Required</b> - 
    #                Description of required param
    # [option2]      <em>Optional</em> - 
    #                Description of optional param
    # [option3]      <em>Optional</em> - 
    #                Description of optional param
    # [option4]      <em>Optional</em> - 
    #                Description of optional param

    def self.where(conditions)
      stop_id = conditions.delete :stop_id
      app_id  = conditions.delete(:app_id) || 'na'

      raise ArgumentError.new('You must provide a stop ID') unless stop_id
      Ratis.all_conditions_used? conditions

      response = Request.get 'Nextbus2', { 'Stopid' => stop_id, 'Appid' => app_id }
      return [] unless response.success?

      stops = response.to_array :nextbus2_response, :stops, :stop
      runs  = response.to_array :nextbus2_response, :runs, :run

      NextBus.new stops, runs
    end

    # Gets description of first stop
    # @return [String] Description of first stop or nil.

    def first_stop_description
      stops.first ? stops.first[:description] : nil
    end

    # Details of NextBus instance in a hash.
    # @return     [Hash] NextBus details in a hash.

    def to_hash
      { :stopname => first_stop_description,
        :signs    => runs.map { |run| run[:sign] }.uniq,
        :runs     => runs.map do |run|
          { :time      => run[:estimatedtime],
            :sign      => run[:sign],
            :adherence => run[:adherence],
            :route     => run[:route]
          }
        end
      }
    end

    # Details of NextBus instance in a hash to be transformed to xml
    # @private

    def to_hash_for_xml
      { :stopname => first_stop_description,
        :runs     => runs.map do |run|
          { :time           => run[:estimatedtime],
            :scheduled_time => run[:triptime],
            :sign           => run[:sign],
            :adherence      => run[:adherence],
            :route          => run[:route]
          }
        end
      }
    end
  end

end
