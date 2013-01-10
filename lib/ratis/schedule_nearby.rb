module Ratis

  class ScheduleNearby

    attr_accessor :atstops

    def self.where(conditions)
      latitude = conditions.delete :latitude
      longitude = conditions.delete :longitude
      date = conditions.delete :date
      time = conditions.delete :time
      window = conditions.delete :window
      walk_distance = conditions.delete :walk_distance
      landmark_id = conditions.delete :landmark_id
      stop_id = conditions.delete(:stop_id) || ''
      app_id = conditions.delete(:app_id) || 'na'

      raise ArgumentError.new('You must provide latitude') unless latitude
      raise ArgumentError.new('You must provide longitude') unless longitude
      raise ArgumentError.new('You must provide date') unless date
      raise ArgumentError.new('You must provide time') unless time
      raise ArgumentError.new('You must provide window') unless window
      raise ArgumentError.new('You must provide walk_distance') unless walk_distance
      raise ArgumentError.new('You must provide landmark_id') unless landmark_id
      Ratis.all_conditions_used? conditions

      response = Request.get 'Schedulenearby',
        {'Locationlat' => latitude, 'Locationlong' => longitude,
         'Date' => date, 'Time' => time, 'Window' => window, 'Walkdist' => walk_distance,
         'Landmarkid' => landmark_id, 'Stopid' => stop_id, 'Appid' => app_id
        }

      return [] unless response.success?

      atstops = response.to_array :schedulenearby_response, :atstop
      atstops.map do |atstop|
        atstop[:services] = atstop.to_array :service

        atstop[:services].map do |service|
          service[:tripinfos] = service.to_array :tripinfo
        end
      end

      schedule_nearby = ScheduleNearby.new
      schedule_nearby.atstops = atstops

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
