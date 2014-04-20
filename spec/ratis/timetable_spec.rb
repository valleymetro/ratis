require 'spec_helper'

describe Ratis::Timetable do
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
      @conditions = {:route_short_name => 'ZERO',
                     :direction        => 'N',
                     :service_type     => 'W',
                     :date             => @today}
    end

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Timetable.where(@conditions.dup)
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Timetable')
        options["Route"].should eq('ZERO')
        options["Direction"].should eq('N')
        options["Date"].should eq(@today)
        options["Servicetype"].should be_nil

      end.and_return(double('response', :success? => false))

      Ratis::Timetable.where(@conditions.dup)
    end

    it 'should return a collection Timetable::Stop(s)' do

      timetable = Ratis::Timetable.where(@conditions.dup)
      timetable.timepoints.each do |obj|
        expect(obj).to be_a(Ratis::Timetable::Stop)
      end

    end

    it 'should return a collection Timetable::Stop(s)' do

      timetable = Ratis::Timetable.where(@conditions.dup)
      timetable.trips.each do |obj|
        expect(obj).to be_a(Ratis::Timetable::Trip)
      end
      puts timetable.trips.size
    end

    it "should parse the timetable/stop/trip fields" do
      timetable = Ratis::Timetable.where(@conditions.dup)

      expect(timetable.route_short_name).to eq('ZERO')
      expect(timetable.direction).to eq('N')
      expect(timetable.service_type).to eq('Weekday')
      expect(timetable.operator).to eq('AP')
      expect(timetable.effective).to eq('10/28/13')

      stop = timetable.timepoints.first

      expect(stop.ratis_stop_id).to eq(0)
      expect(stop.atis_stop_id).to eq('3317')
      expect(stop.stop_id).to eq('10050')
      expect(stop.description).to eq('CENTRAL AVE &amp; DOBBINS RD')
      expect(stop.area).to eq('Phoenix')

      trip = timetable.trips.first

      expect(trip.ratis_stop_id).to eq(0)
      expect(trip.times).to eq( ["05:10 AM", "05:14 AM", "05:22 AM", "05:35 AM", "05:43 AM", "05:51 AM", "05:59 AM", "06:10 AM"] )
      expect(trip.comment).to eq('F')

    end

    it "should raise error for missing arg route_short_name" do
      conditions = @conditions.dup
      conditions.delete(:route_short_name)

      expect do
        Ratis::Timetable.where(conditions)
      end.to raise_error(ArgumentError, 'You must provide a route_short_name')
    end

    it "should raise error for missing arg direction" do
      conditions = @conditions.dup
      conditions.delete(:direction)

      expect do
        Ratis::Timetable.where(conditions)
      end.to raise_error(ArgumentError, 'You must provide a direction')
    end

    it "should raise error for missing arg date" do
      conditions = @conditions.dup
      conditions.delete(:date)
      conditions.delete(:service_type)

      expect do
        Ratis::Timetable.where(conditions)
      end.to raise_error(ArgumentError, 'You must provide either date or service_type')
    end

    describe 'ATIS call' do
    it "should not throw a 500" do
      # This test was added because while our test suite was passing 2/18/14 the real API was throwing 500s and we want to know about things like that. CI
      @today      = Time.now.strftime("%m/%d/%Y")
      @conditions = {:route_short_name => 'ZERO',
                     :direction        => 'N',
                     :service_type     => 'W',
                     :date             => @today}
      expect {
        Ratis::Timetable.where(@conditions.dup)
      }.to_not raise_exception(Ratis::Errors::SoapError)
    end
  end
  end

end

