require 'spec_helper'

describe Ratis::Pattern do

  describe '#all' do

    before do
      resp = atis_response_pattern({ :route => '0', :direction => 'N', :date => '01/28/2013', :servicetype => 'W', :longest => 'N' })
      stub_atis_request.to_return( atis_response 'Getpatterns', '1.1', '0', resp)

      @pattern = Ratis::Pattern.all :route_short_name => '0', :direction => 'N', :date => '01/28/2013', :service_type => 'W', :longest => 'N'
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'requests the correct SOAP action' do
      an_atis_request_for('Getpatterns', 'Route' => '0', 'Direction' => 'N', 'Date' => '01/15/13', 'Servicetype' => 'W', 'Longest' => 'N').should have_been_made
    end

    it 'assigns settings correctly' do
      @pattern.should_not be_nil

      @pattern.route_short_name.should eql '0'
      @pattern.direction.should eql 'N'
      @pattern.date.should eql '01/28/2013'
      @pattern.service_type.should eql 'W'
      @pattern.longest.should eql 'N'
    end

  end

end

