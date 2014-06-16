require 'spec_helper'

describe Ratis::Timetable do
  describe '#where', vcr: {} do
    let(:date)    { Chronic.parse('tomorrow at 8am').strftime('%m/%d/%y') }
    let(:options) { { :service_type=>"W", :route_short_name=>"ZERO", :direction=>"N", date: date } }

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Timetable.where(options.dup)
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Timetable')
        options["Route"].should eq('ZERO')
        options["Direction"].should eq('N')
        options["Date"].should eq(date)
        options["Servicetype"].should be_nil

      end.and_return(double('response', :success? => false))

      Ratis::Timetable.where(options.dup)
    end

    it 'should return a collection Timetable::Stop(s)' do
      timetable = Ratis::Timetable.where(options.dup)
      timetable.timepoints.each do |obj|
        expect(obj).to be_a(Ratis::Timetable::Stop)
      end
    end

    it 'should return a collection Timetable::Stop(s)' do
      timetable = Ratis::Timetable.where(options.dup)
      timetable.trips.each do |obj|
        expect(obj).to be_a(Ratis::Timetable::Trip)
      end
      puts timetable.trips.size
    end

    it "should parse the timetable/stop/trip fields" do
      timetable = Ratis::Timetable.where(options.dup)

      expect(timetable.route_short_name).to eq('ZERO')
      expect(timetable.direction).to eq('N')
      expect(timetable.service_type).to eq('Weekday')
      expect(timetable.operator).to eq('AP')
      expect(timetable.effective).to eq('04/28/14')

      stop = timetable.timepoints.first

      expect(stop.ratis_stop_id).to eq(0)
      expect(stop.atis_stop_id).to eq('3317')
      expect(stop.stop_id).to eq('10050')
      expect(stop.description).to eq('CENTRAL AVE & DOBBINS RD')
      expect(stop.area).to eq('Phoenix')

      trip = timetable.trips.first

      expect(trip.ratis_stop_id).to eq(0)
      expect(trip.times).to eq( ["05:10 AM", "05:14 AM", "05:22 AM", "05:35 AM", "05:43 AM", "05:51 AM", "05:59 AM", "06:10 AM"] )
      expect(trip.comment).to eq('F')

    end

    it "should raise error for missing arg route_short_name" do
      conditions = options.dup
      conditions.delete(:route_short_name)
      expect do
        Ratis::Timetable.where(conditions)
      end.to raise_error(ArgumentError, 'You must provide a route_short_name')
    end

    it "should raise error for missing arg direction" do
      conditions = options.dup
      conditions.delete(:direction)
      expect do
        Ratis::Timetable.where(conditions)
      end.to raise_error(ArgumentError, 'You must provide a direction')
    end

    it "should raise error for missing arg date" do
      conditions = options.dup
      conditions.delete(:date)
      conditions.delete(:service_type)
      expect do
        Ratis::Timetable.where(conditions)
      end.to raise_error(ArgumentError, 'You must provide either date or service_type')
    end

    describe 'ATIS call' do
      it "should not throw a 500" do
        # This test was added because while our test suite was passing 2/18/14 the real API was throwing 500s and we want to know about things like that. CI
        expect {
          Ratis::Timetable.where({
            :route_short_name => 'ZERO',
            :direction        => 'N',
            :service_type     => 'W',
            :date             => Time.now.strftime("%m/%d/%Y")
          })
        }.to_not raise_error
      end
    end
  end

end

