require 'spec_helper'

describe Ratis::Timetable do

  describe '#where' do

    before do
      resp = atis_response_timetable({ :route => '0', :direction => 'N', :service_type => 'W', :operator => 'OP', :effective => '01/15/12' })
      stub_atis_request.to_return( atis_response 'Timetable', '1.1', '0', resp)

      @timetable = Ratis::Timetable.where :route_short_name => '0', :direction => 'N', :service_type => 'W'
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'requests the correct SOAP action' do
      an_atis_request_for('Timetable', 'Route' => '0', 'Direction' => 'N', 'Servicetype' => 'W').should have_been_made
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

end

