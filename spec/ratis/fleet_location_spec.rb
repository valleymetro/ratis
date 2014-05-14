require 'spec_helper'

describe Ratis::FleetLocation do

  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-271/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  describe "#current" do
    before do
      @conditions = {:app_id => 'WEB'}
    end

    it 'only makes one request', vcr: {} do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::FleetLocation.current(@conditions.dup)
    end

    it 'requests the correct SOAP action' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Fleetlocation')
        options["Appid"].should eq(@conditions[:app_id])

      end.and_return(double('response', :success? => false))

      Ratis::FleetLocation.current(@conditions.dup)
    end

    it "should return a collection of Ratis::Vehicle(s)", vcr: {} do
      stops = Ratis::FleetLocation.current(@conditions.dup)
      stops.each do |obj|
        expect(obj).to be_a(Ratis::Vehicle)
      end
    end

    it 'returns multiple vehicles', vcr: {} do
      stops = Ratis::FleetLocation.current(@conditions.dup)
      stops.should have(403).items
    end

    it 'parses out the vehicle fields correctly', vcr: {} do
      vehicles = Ratis::FleetLocation.current(@conditions.dup)
      vehicle  = vehicles.first

      expect(vehicle.route).to eq('1')
      expect(vehicle.direction).to eq('E')
      expect(vehicle.updatetime).to eq('02:08 PM')
      expect(vehicle.adherance).to eq('0')
      expect(vehicle.adhchange).to eq('S')
      expect(vehicle.vehicle_id).to be_nil
      expect(vehicle.offroute).to eq('N')
      expect(vehicle.stopped).to eq('N')
      expect(vehicle.reliable).to eq('Y')
      expect(vehicle.inservice).to eq('Y')
    end

  end

end
