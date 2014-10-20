module Ratis

  class ScheduleNearby

    attr_accessor :atstops

    def self.where(conditions)
      keys = conditions.keys

      if keys.include? :latitude
        raise ArgumentError.new('You must provide longitude') unless keys.include?(:longitude)
      elsif keys.include? :longitude
        raise ArgumentError.new('You must provide latitude') unless keys.include?(:latitude)
      else
        raise ArgumentError.new('You must provide stop_id') unless keys.include?(:stop_id)
      end

      latitude      = conditions.delete(:latitude)
      longitude     = conditions.delete(:longitude)
      date          = conditions.delete(:date)
      time          = conditions.delete(:time)
      window        = conditions.delete(:window)
      walk_distance = conditions.delete(:walk_distance)
      landmark_id   = conditions.delete(:landmark_id)
      stop_id       = conditions.delete(:stop_id) || ''

      raise ArgumentError.new('You must provide date') unless date
      raise ArgumentError.new('You must provide time') unless time
      raise ArgumentError.new('You must provide window') unless window
      raise ArgumentError.new('You must provide walk_distance') unless walk_distance

      Ratis.all_conditions_used? conditions

      response = Request.get 'Schedulenearby',
                            {'Locationlat'  => latitude,
                             'Locationlong' => longitude,
                             'Date'         => date,
                             'Time'         => time,
                             'Window'       => window,
                             'Walkdist'     => walk_distance,
                             'Landmarkid'   => landmark_id,
                             'Stopid'       => stop_id
                            }

      return [] unless response.success?

      # TODO: where is this nightmare-ish hash being used?
      # need to refactor this into something more OO
      atstops = response.to_array :schedulenearby_response, :atstop
      atstops.each do |atstop|
        atstop[:services] = atstop.to_array :service

        atstop[:services].each do |service|
          service[:tripinfos] = service.to_array :tripinfo
        end
      end

      schedule_nearby = ScheduleNearby.new
      schedule_nearby.atstops = atstops.collect { |stop| Hashie::Mash.new stop }

      schedule_nearby
    end

    def to_hash
      {
        :atstops => atstops.map do |atstop|
          {
            :description    => atstop[:description],
            :walkdist       => atstop[:walkdist],
            :walkdir        => atstop[:walkdir],
            :stopid         => atstop[:stopid],
            :heading        => atstop[:heading],
            :lat            => atstop[:lat],
            :long           => atstop[:long],
            :services       => atstop[:services].map do |service|
              {
                :route      => service[:route],
                :routetype  => service[:routetype],
                :operator   => service[:operator],
                :sign       => service[:sign],
                :times      => service[:times],
                :trips      => service[:tripinfos].map do |tripinfo|
                  { :triptime => tripinfo[:triptime] }
                end
              }
            end
          }
        end
      }
    end

  end

end
