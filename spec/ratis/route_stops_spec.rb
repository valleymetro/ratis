require 'spec_helper'

describe Ratis::RouteStops do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  describe '.all', vcr: {} do

    before do
      @today      = Time.now.strftime("%m/%d/%Y")
      @conditions = {:route     => '1',
                     :direction => 'E',
                     :order     => 'A' }
    end

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::RouteStops.all(@conditions.dup)
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Routestops')
        options["Route"].should eq('1')
        options["Direction"].should eq('E')
        options["Order"].should eq('A')

      end.and_return(double('response', :success? => false))

      Ratis::RouteStops.all(@conditions.dup)
    end

    it 'should return a collection of Ratis::RouteStops::Stop(s)' do
      route_stops = Ratis::RouteStops.all(@conditions.dup)
      route_stops.each do |obj|
        expect(obj).to be_a(Ratis::RouteStops::Stop)
      end
    end

    it 'parses out the stop fields correctly' do
      route_stops = Ratis::RouteStops.all(@conditions.dup)
      stop        = route_stops.first

      expect(stop.description).to eq('7TH ST & VAN BUREN ST')
      expect(stop.area).to eq('Phoenix')
      expect(stop.atis_stop_id).to eq('4390')
      expect(stop.stop_seq).to eq('20')
      expect(stop.stop_id).to be_nil
      expect(stop.point).to be_nil
      expect(stop.alpha_seq).to be_nil
      expect(stop.latitude).to eq('33.450994')
      expect(stop.longitude).to eq('-112.065249')
    end

    it "should raise error for missing arg route" do
      conditions = @conditions.dup
      conditions.delete(:route)

      expect do
        Ratis::RouteStops.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a route')
    end

    it "should raise error for missing arg direction" do
      conditions = @conditions.dup
      conditions.delete(:direction)

      expect do
        Ratis::RouteStops.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a direction')
    end

  end

end

