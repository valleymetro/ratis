module Ratis

  class NextBus

    attr_accessor :stop, :services, :success

    def initialize(response)
      @success  = response.success?
      @stop     = []
      @services = []

      if @success
        @stop = response.body[:nextbus_response][:atstop]

        # Only Light Rail stops will return 2 stops from ATIS for a single NextRide id
        if @stop.is_a?(Array)
          @stop.each do |_stop|
            parse_stop(_stop)
          end
        else
          parse_stop(@stop)
        end

      end

    end

    def parse_stop(single_stop)
      _services = single_stop.delete(:service)

      _services = [_services] unless _services.is_a?(Array)

      @services << _services.map do |service|
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

      @services.flatten!
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
      type    = conditions.delete(:type)   || 'N' # N for Next Bus

      if datetime = conditions.delete(:datetime)
        raise ArgumentError.new('If datetime supplied it should be a Time or DateTime instance, otherwise it defaults to Time.now') unless datetime.is_a?(DateTime) || datetime.is_a?(Time)
      else
        datetime = Time.now
      end

      raise ArgumentError.new('You must provide a stop ID') unless stop_id

      Ratis.all_conditions_used?(conditions)

      response = Request.get 'Nextbus', {'Stopid' => stop_id,
                                         'Date' => datetime.strftime("%m/%d/%Y"),
                                         'Time' => datetime.strftime("%H%M"),
                                         'Type' => type }

      NextBus.new(response)
    end

    def success?
      @success
    end

    def stop_description
      if @stop.is_a?(Array)
        @stop.first[:description]
      else
        @stop[:description]
      end
    end

    # Used to create an XML response for the NextBus SMS services which hits
    # /nextride.xml?stop_id=<STOPID>

    def to_hash_for_xml
      { :stopname => stop_description,
        :runs     => @services.map do |service|
                       service.trips.map do |trip|

                         { :time      => trip.realtime.estimatedtime,
                           :sign      => service.sign,
                           :adherence => trip.realtime.adherence,
                           :route     => service.route
                         }
                       end
                     end.flatten

      }
    end
  end

end
