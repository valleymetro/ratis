require 'spec_helper'

describe Ratis::Pattern do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-252/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  describe '#all' do

    before do
      @today      = Time.now.strftime("%m/%d/%Y")
      @conditions = {:route_short_name => '0',
                     :direction        => 'N',
                     :date             => @today,
                     :service_type     => 'W',
                     :longest          => 'N'}
    end

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Pattern.all(@conditions.dup)
    end

    it 'should return no data error when date is in the past' do
      old_date_conditions = @conditions.merge(:date => '01/28/2013')
      expect do
        Ratis::Pattern.all(old_date_conditions)
      end.to raise_error(Ratis::Errors::SoapError, "error #1007--Record not found or no more data")
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Getpatterns')
        options["Route"].should eq('0')
        options["Direction"].should eq('N')
        options["Date"].should eq(@today)
        options["Servicetype"].should eq('W')
        options["Longest"].should eq('N')

      end.and_return(double('response', :success? => false))

      Ratis::Pattern.all(@conditions.dup)
    end

    it 'should return a collection Pattern::RouteInfo(s)' do

      pattern = Ratis::Pattern.all(@conditions.dup)
      pattern.routeinfos.each do |obj|
        expect(obj).to be_a(Ratis::Pattern::RouteInfo)
      end

    end

    it "should parse the route info fields" do
      pattern   = Ratis::Pattern.all(@conditions.dup)
      routeinfo = pattern.routeinfos.first

      expect(routeinfo.operate).to eq('AP')
      expect(routeinfo.routetype).to eq('B')
      expect(routeinfo.headsign).to eq("0 CENTRAL North to Dunlap/3rd St.")
      expect(routeinfo.routeid).to eq('61540')
      expect(routeinfo.route).to eq('0')
      expect(routeinfo.school).to be_nil
      expect(routeinfo.effective).to eq('01/28/13')
      expect(routeinfo.tripcount).to eq('51')

    end

    it "should raise error for missing arg route_short_name" do
      conditions = @conditions.dup
      conditions.delete(:route_short_name)

      expect do
        Ratis::Pattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a route_short_name')
    end

    it "should raise error for missing arg direction" do
      conditions = @conditions.dup
      conditions.delete(:direction)

      expect do
        Ratis::Pattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a direction')
    end

    it "should raise error for missing arg date" do
      conditions = @conditions.dup
      conditions.delete(:date)

      expect do
        Ratis::Pattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a date')
    end

    it "should raise error for missing arg service_type" do
      conditions = @conditions.dup
      conditions.delete(:service_type)

      expect do
        Ratis::Pattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a service_type')
    end

    it "should raise error for missing arg longest" do
      conditions = @conditions.dup
      conditions.delete(:longest)

      expect do
        Ratis::Pattern.all(conditions)
      end.to raise_error(ArgumentError, 'You must provide a longest')
    end

  end

end

