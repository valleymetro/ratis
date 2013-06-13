module Ratis

  class NextBus

    attr_accessor :stop, :services, :success

    def initialize(response)
      @success = response.success?

      if @success
        @stop     = response.body[:nextbus_response][:atstop]

        _services = @stop.delete(:service)

        unless _services.is_a?(Array)
          _services = [_services]
        end

        @services = _services.map do |service|
          OpenStruct.new(:status      => service[:status],
                         :sign        => service[:sign],
                         :routetype   => service[:routetype],
                         :times       => service[:times],
                         :direction   => service[:direction],
                         :servicetype => service[:servicetype],
                         :route       => service[:route],
                         :operator    => service[:operator],
                         :trips       => parse_trip_info(service[:tripinfo])
                         )
        end

      else
        @stop = {}
        @services = []
      end

    end

    def parse_trip_info(trips)
      # can come back as an Array or single Hash...
      if trips.is_a?(Array)
        trips.map do |ti|
          create_trip(ti)
        end
      else # Hash
        [create_trip(trips)]
      end
    end

    # TODO: turn into real classes
    def create_trip(trip)
      OpenStruct.new(:triptime   => trip[:triptime],
                     :block      => trip[:block],
                     :tripid     => trip[:tripid],
                     :exception  => trip[:exception],
                     :skedtripid => trip[:skedtripid],
                     :realtime   => OpenStruct.new(:valid            => trip[:realtime][:valid],
                                                   :adherence        => trip[:realtime][:adherence],
                                                   :estimatedtime    => trip[:realtime][:estimatedtime],
                                                   :estimatedminutes => trip[:realtime][:estimatedminutes],
                                                   :polltime         => trip[:realtime][:polltime],
                                                   :trend            => trip[:realtime][:trend],
                                                   :speed            => trip[:realtime][:speed],
                                                   :reliable         => trip[:realtime][:reliable],
                                                   :stopped          => trip[:realtime][:stopped],
                                                   :lat              => trip[:realtime][:lat],
                                                   :long             => trip[:realtime][:long] ))
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

      Ratis.all_conditions_used?(conditions)

      response = Request.get 'Nextbus', {'Stopid' => stop_id,
                                         'Appid' => app_id,
                                         'Date' => datetime.strftime("%m/%d/%Y"),
                                         'Time' => datetime.strftime("%H%M"),
                                         'Type' => type }

      NextBus.new(response)
    end

    def success?
      @success
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

      { :stopname => @stop[:description],
        :signs    => @services.map(&:sign).uniq,
        :runs     => @services.map do |service|
                       service.trips.map do |realtime|
                         { :time      => realtime[:estimatedtime],
                           :sign      => realtime[:sign],
                           :adherence => realtime[:adherence],
                           :route     => realtime[:route]
                         }
                       end
                     end.flatten

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
