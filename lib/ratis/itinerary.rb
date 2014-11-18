module Ratis
  class Itinerary < Hashie::Trash
    property :legs, transform_with: (lambda do |legs|
      Array.wrap(legs[:leg]).map { |l| Hashie::Mash.new l }
    end)

    property :total_walk, from: :totalwalk
    property :final_walk, from: :finalwalk
    property :final_walk_dir, from: :finalwalkdir
    property :final_walk_hint, from: :finalwalkhint
    property :transit_time, from: :transittime, with: lambda { |v| v.to_i }
    property :regular_fare, from: :regularfare, with: lambda { |v| v.to_f }
    property :reduced_fare, from: :reducedfare, with: lambda { |v| v.to_f }
    property :fare_info, from: :fareinfo
    property :trace_info, from: :traceinfo
    property :status_info, from: :statusinfo
    property :exmodified
    property :exmodids
    property :dist_transit, from: :disttransit, with: lambda { |v| v.to_f }
    property :dist_auto, from: :distauto, with: lambda { |v| v.to_f }
    property :co2_transit, from: :co2transit, with: lambda { |v| v.to_f }
    property :co2_auto, from: :co2auto, with: lambda { |v| v.to_f }
  end
end
