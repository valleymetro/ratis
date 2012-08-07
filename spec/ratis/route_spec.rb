require 'spec_helper'

describe Ratis::Route do

  describe '#all' do

    before do
      stub_atis_request.to_return( atis_response 'Allroutes', '1.5', '0', <<-BODY )
        <Routes>
          0, N, S
          1, E, W
        </Routes>
      BODY

      @all_routes = Ratis::Route.all
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'gets all routes' do
      @all_routes.should have(2).items
    end

    it 'gets all route directions' do
      @all_routes.each do |route|
        route.should have(2).directions
      end
    end

  end

  describe '#timetable' do

    let(:route) { Ratis::Route.new '0', ['N', 'S'] }

    before do
      resp = atis_response_timetable({ :route => '0', :direction => 'N', :service_type => 'W', :operator => 'OP', :effective => '01/15/12' })
      stub_atis_request.to_return( atis_response 'Timetable', '1.1', '0', resp)

      @timetable = route.timetable :direction => 'N', :service_type => 'W'
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'assigns settings correctly' do
      @timetable.should_not be_nil

      @timetable.route_short_name.should eql '0'
      @timetable.direction.should eql 'N'
      @timetable.service_type.should eql 'W'
      @timetable.operator.should eql 'OP'
      @timetable.effective.should eql '01/15/12'
    end

  end

  it 'should initialize' do
    route = Ratis::Route.new '123', ['N', 'S']

    route.short_name.should eql '123'
    route.directions.should eql ['N', 'S']
  end

end
