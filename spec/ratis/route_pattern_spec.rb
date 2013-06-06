require 'spec_helper'

describe Ratis::RoutePattern do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint  = 'http://soap.valleymetro.org/cgi-bin-soap-web-252/soap.cgi'
      config.namespace = 'PX_WEB'
    end
  end

  describe '#where' do

    before do
      @today      = Chronic.parse('tomorrow at 8am') # Time.now.strftime("%m/%d/%Y")
      @conditions = {:route_short_name => '0',
                     :direction        => 'N',
                     :date             => @today,
                     :service_type     => 'W',
                     :routeid          => '83720' }
    end

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::RoutePattern.all(@conditions.dup)
    end

    it 'requests the correct SOAP action' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Routepattern')
        options["Route"].should eq('0')
        options["Direction"].should eq('N')
        options["Date"].should eq(@today)
        options["Servicetype"].should eq('W')
        options["Routeid"].should eq('83720')

      end.and_return(double('response', :success? => false))

      Ratis::RoutePattern.all(@conditions.dup)
    end

    it 'should return a collection Ratis::RoutePattern::Stop(s)' do
      routepattern = Ratis::RoutePattern.all(@conditions.dup)
      routepattern.stops.each do |obj|
        expect(obj).to be_a(Ratis::RoutePattern::Stop)
      end

    end

    it 'should return a collection Ratis::RoutePattern::Point(s)' do
      routepattern = Ratis::RoutePattern.all(@conditions.dup)
      routepattern.points.each do |obj|
        expect(obj).to be_a(Ratis::RoutePattern::Point)
      end

    end

    it 'should parse the stop fields' do
      routepattern = Ratis::RoutePattern.all(@conditions.dup)
      stop         = routepattern.stops.first

      expect(stop.desc).to eq('CENTRAL AVE & DOBBINS RD')
      expect(stop.area).to eq('Phoenix')
      expect(stop.atisid).to eq('3317')
      expect(stop.stopid).to eq('10050')
      expect(stop.point).to eq("33.36369,-112.07319")
      expect(stop.lat).to eq('33.36369')
      expect(stop.lng).to eq('-112.07319')
      expect(stop.boardflag).to eq('E')
      expect(stop.timepoint).to eq('Y')
    end

    it "should raise error for missing arg route_short_name" do
      conditions = @conditions.dup
      conditions.delete(:route_short_name)

      expect do
        Ratis::RoutePattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a route_short_name')
    end

    it "should raise error for missing arg direction" do
      conditions = @conditions.dup
      conditions.delete(:direction)

      expect do
        Ratis::RoutePattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a direction')
    end

    it "should raise error for missing arg date" do
      conditions = @conditions.dup
      conditions.delete(:date)

      expect do
        Ratis::RoutePattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a date')
    end

    it "should raise error for missing arg service_type" do
      conditions = @conditions.dup
      conditions.delete(:service_type)

      expect do
        Ratis::RoutePattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a service_type')
    end

    it "should raise error for missing arg routeid" do
      conditions = @conditions.dup
      conditions.delete(:routeid)

      expect do
        Ratis::RoutePattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a routeid')
    end


  end

end

