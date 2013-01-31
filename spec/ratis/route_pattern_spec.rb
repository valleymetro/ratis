require 'spec_helper'

describe Ratis::Routepattern do

  describe '#where' do

    before do
      resp = atis_response_routepattern({ :route => '0', :direction => 'N', :date => '01/28/2013', :servicetype => 'W', :routeid => '61540' })
      stub_atis_request.to_return( atis_response 'Routepattern', '1.1', '0', resp)

      @routepattern = Ratis::Routepattern.all :route_short_name => '0', :direction => 'N', :date => '01/28/2013', :service_type => 'W', :routeid => '61540'
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'requests the correct SOAP action' do
      an_atis_request_for('Routepattern', 'Route' => '0', 'Direction' => 'N', 'Date' => '01/28/2013', 'Servicetype' => 'W', 'Routeid' => '61540').should have_been_made
    end

    it 'assigns settings correctly' do
      @routepattern.should_not be_nil

      @routepattern.route_short_name.should eql '0'
      @routepattern.direction.should eql 'N'
      @routepattern.date.should eql '01/28/2013'
      @routepattern.service_type.should eql 'W'
      @routepattern.routeid.should eql '61540'
    end

  end

end

