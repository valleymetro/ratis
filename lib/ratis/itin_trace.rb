module Ratis

  class ItinTrace

    attr_accessor :success, :legs, :map_extents

    def initialize(response)
      @success     = response.success?
      @map_extents = response.body[:itintrace_response][:mapextents].split(',').map(&:to_f).each_slice(2).to_a
      @legs        = response.body.to_array(:itintrace_response, :legs, :leg).map { |l| Hashie::Mash.new l }

      @legs.each do |leg|
        leg.points = leg.to_array(:points, :point).collect do |point|
          point.split(',').map(&:to_f)
        end
      end
    end

    def self.for_tid(tid, trace_info)
      response = Request.get 'Itintrace', {'Tid' => tid, 'Traceinfo' => trace_info}
      ItinTrace.new(response)
    end

    def success?
      @success
    end
  end

end

