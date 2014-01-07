require 'spec_helper'

describe Ratis::ClosestStop do

  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  describe '#where', vcr: {} do
    before do
      @today      = Time.now.strftime("%m/%d/%Y")
      @conditions = {:latitude      => '33.4556',
                     :longitude     => '-112.071807',
                     :location_text => 'some location text',
                     :num_stops     => '15'}
    end

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::ClosestStop.where(@conditions.dup)
    end

    it 'requests the correct SOAP action' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Closeststop')
        options["Locationlat"].should eq(@conditions[:latitude])
        options["Locationlong"].should eq(@conditions[:longitude])
        options["Locationtext"].should eq(@conditions[:location_text])
        options["Numstops"].should eq(@conditions[:num_stops])

      end.and_return(double('response', :success? => false))

      Ratis::ClosestStop.where(@conditions.dup)
    end

    it "should return a collection of Ratis::Stop(s)" do
      stops = Ratis::ClosestStop.where(@conditions.dup)
      stops.each do |obj|
        expect(obj).to be_a(Ratis::Stop)
      end
    end

    it 'returns multiple locations' do
      stops = Ratis::ClosestStop.where(@conditions.dup)
      stops.should have(15).items
    end

    it 'ignores a <Stop> without a blank <Description>' do
      pending('Update specs to use new namespaced stop classes')
      pending 'not sure if this is the correct behaviour'
    end

    it 'parses out the stop fields correctly' do
      stops = Ratis::ClosestStop.where(@conditions.dup)
      stop  = stops.first

      expect(stop.latitude.to_f).to be_within(0.001).of(33.454494)
      expect(stop.longitude.to_f).to be_within(0.001).of(-112.070508.to_f)
      expect(stop.area).to eq('Phoenix')
      expect(stop.walk_dir).to eq('SE')
      expect(stop.stop_position).to eq('Y')
      expect(stop.description).to eq('FILLMORE ST & 3RD ST')
      expect(stop.walk_dist).to eq('0.15')
      expect(stop.side).to eq('Far')
      expect(stop.stop_id).to eq('10606')
      expect(stop.heading).to eq('WB')
      expect(stop.atis_stop_id).to eq('5648')
      expect(stop.route_dirs).to eql({:routedir=>"7-S"})
      expect(stop.route_dir).to eq('7-S')
    end

    it "should raise error for missing arg latitude" do
      conditions = @conditions.dup
      conditions.delete(:latitude)

      expect do
        Ratis::ClosestStop.where(conditions)
      end.to raise_error(ArgumentError, 'You must provide a latitude')
    end

    it "should raise error for missing arg longitude" do
      conditions = @conditions.dup
      conditions.delete(:longitude)

      expect do
        Ratis::ClosestStop.where(conditions)
      end.to raise_error(ArgumentError, 'You must provide a longitude')
    end
  end



end

