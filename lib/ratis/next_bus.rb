module Ratis

  class NextBus

    attr_accessor :runs, :status, :sign, :routetype, :times, :direction

    def initialize(service, _runs = [])
      @runs      = _runs

      @status    = service[:status]
      @sign      = service[:sign]
      @routetype = service[:routetype]
      @times     = service[:times]
      @direction = service[:direction]
    end

    def self.where(conditions)
      stop_id = conditions.delete(:stop_id)
      app_id  = conditions.delete(:app_id) || 'ratis-gem'
      type    = conditions.delete(:type) || 'N' # N for Next Bus

      if datetime = conditions.delete(:datetime)
        raise ArgumentError.new('If datetime supplied it should be a Time or DateTime instance, otherwise it defaults to Time.now') unless datetime.is_a?(DateTime) || datetime.is_a?(Time)
      else
        datetime = Time.now
      end

      raise ArgumentError.new('You must provide a stop ID') unless stop_id

      Ratis.all_conditions_used? conditions

      response = Request.get 'Nextbus', {'Stopid' => stop_id,
                                         'Appid' => app_id,
                                         'Date' => datetime.strftime("%m/%d/%Y"),
                                         'Time' => datetime.strftime("%I%M"),
                                         'Type' => type }
      return [] unless response.success?

      service = response.body[:nextbus_response][:atstop][:service]
      runs    = response.to_array :nextbus_response, :atstop, :service, :tripinfo
      NextBus.new service, runs
    end

    # Gets description of first stop
    # @return [String] Description of first stop or nil.

    def first_stop_description
      raise 'Not yet implemented'
      stops.first ? stops.first[:description] : nil
    end

    # Details of NextBus instance in a hash.
    # @return     [Hash] NextBus details in a hash.

    def to_hash
      raise 'Not yet implemented'
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
      raise 'Not yet implemented'
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
