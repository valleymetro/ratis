require 'ratis/atis_model'

class AtisScheduleNearby
  extend AtisModel

  attr_accessor :atstops

  def self.where(criteria)
    latitude = criteria.delete :latitude
    longitude = criteria.delete :longitude
    date = criteria.delete :date
    time = criteria.delete :time
    window = criteria.delete :window
    walk_distance = criteria.delete :walk_distance
    landmark_id = criteria.delete :landmark_id
    stop_id = criteria.delete(:stop_id) || ''
    app_id = criteria.delete(:app_id) || 'na'

    raise ArgumentError.new('You must provide latitude') unless latitude
    raise ArgumentError.new('You must provide longitude') unless longitude
    raise ArgumentError.new('You must provide date') unless date
    raise ArgumentError.new('You must provide time') unless time
    raise ArgumentError.new('You must provide window') unless window
    raise ArgumentError.new('You must provide walk_distance') unless walk_distance
    raise ArgumentError.new('You must provide landmark_id') unless landmark_id

    response = atis_request 'Schedulenearby',
      {'Locationlat' => latitude, 'Locationlong' => longitude,
       'Date' => date, 'Time' => time, 'Window' => window, 'Walkdist' => walk_distance,
       'Landmarkid' => landmark_id, 'Stopid' => stop_id, 'Appid' => app_id
      }

    return [] unless response.success?

    atstops = response.to_array :schedulenearby_response, :atstop
    atstops.collect do |atstop|
      services = atstop.delete :service
      atstop[:services] = services.kind_of?(Array) ? services : [services].compact

      atstop[:services].collect do |service|
        tripinfos = service.delete :tripinfo
        service[:tripinfos] = tripinfos.kind_of?(Array) ? tripinfos : [tripinfos].compact
      end
    end

    schedule_nearby = AtisScheduleNearby.new
    schedule_nearby.atstops = atstops

    schedule_nearby
  end

  def to_hash
    {
      :atstops => atstops.collect do |atstop|
        {
          :description    => atstop[:description],
          :walkdist       => atstop[:walkdist],
          :walkdir        => atstop[:walkdir],
          :stopid         => atstop[:stopid],
          :lat            => atstop[:lat],
          :long           => atstop[:long],
          :services       => atstop[:services].collect do |service|
            {
              :route      => service[:route],
              :routetype  => service[:routetype],
              :operator   => service[:operator],
              :sign       => service[:sign],
              :times      => service[:times],
              :trips      => service[:tripinfos].collect do |tripinfo|
                { :triptime => tripinfo[:triptime] }
              end
            }
          end
        }
      end
    }
  end

private

  def atstop_to_hash

  end


end

