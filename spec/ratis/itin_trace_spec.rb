require 'spec_helper'

describe Ratis::ItinTrace do

  describe '#for_tid', vcr: {} do

    # this tid / trace_info paring created previously by Ratis::Plantrip 'passes a Tid through' spec
    let(:itin_trace) { Ratis::ItinTrace.for_tid 'Here is my Tid', '1|183500|14|15' }

    it 'only makes one request' do
      Ratis::Request.should_receive(:get).once.and_call_original
      itin_trace
    end

    it 'wraps legs in a Hashie::Mash' do
      itin_trace.legs.each do |leg|
        expect(leg).to be_a(Hashie::Mash)
        expect(leg.keys).to eql(["route", "sign", "operator", "hexcolor", "color", "points", "distance", "stops"])
      end
    end

    it 'wraps legs in a Hashie::Mash' do
      itin_trace.legs.each do |leg|
        leg.points.each do |point|
          expect(point).to be_a(Array)
          expect(point.size).to eql(2)
          expect(point.first).to be_a(Float)
          expect(point.last).to be_a(Float)
        end
      end
    end

    it 'pairs up map extents lat/lngs' do
      expect(itin_trace.map_extents).to eql([[33.448232, -112.075282], [33.451444, -112.073659]])
    end
  end

end

