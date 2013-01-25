require 'spec_helper'

describe Ratis::RoutePattern do

  describe '#where' do

    before do
      stub_atis_request.to_return( atis_response 'Routepattern', '1.5', '0', <<-BODY )
      <Stops>
        <Stop>
          <Description>text description of the stop</Description>
          <Area>area description</Area>
          <Lat>32</Lat>
          <Long>60</Long>
          <Point>±dd.nnnnnn, ±ddd.nnnnnn</Point>
          <Atisstopid>NNNNN</Atisstopid>
          <Stopid>string</Stopid>
        </Stop>
        <Stop>
          <Description>text description of the stop 2</Description>
          <Area>area description 2</Area>
          <Lat>322</Lat>
          <Long>602</Long>
          <Point>±dd.nnnnnn, ±ddd.nnnnnn</Point>
          <Atisstopid>SSSSS</Atisstopid>
          <Stopid>string 2</Stopid>
        </Stop>
      </Stops>
      BODY

      @stops = Ratis::RoutePattern.where :date => "11/11/11", :routeid => '777', :direction => 'N'
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'requests the correct SOAP action' do
      an_atis_request_for('Routepattern', { 'Date' => '11/11/11', 'Routeid' => '777', 'Direction' => 'N'} ).should have_been_made
    end


    ##### The three tests below do not pass right now. Not sure of correct syntax.

    #fail if date isn't provided
    it 'should fail if date isn\'t provide' do
      expect{an_atis_request_for('Routepattern', 'Routeid' => '777', 'Direction' => 'N')}.to raise_error(RoutePattern::ArgumentError, "You must provide a date")
    end

    #fail if routeid isn't provided
    it 'should fail if routeid isn\'t provided' do
      expect{an_atis_request_for('Routepattern', 'Date' => '11/11/11', 'Direction' => 'N')}.to raise_error(ArgumentError, "You must provide a routeid")
    end

    #fail if direction isn't provided
    it 'should fail if direction isn\'t provided' do
      expect{an_atis_request_for('Routepattern', 'Routeid' => '777', 'Date' => '11/11/11')}.to raise_error(ArgumentError, "You must provide a direction")
    end




    it 'should return all stops' do
      @stops.should have(2).items

      @stops[0].description.should eql 'text description of the stop'
      @stops[0].area.should eql 'area description'
      @stops[0].lat.should eql '32'
      @stops[0].long.should eql '60'
      @stops[0].point.should eql '±dd.nnnnnn, ±ddd.nnnnnn'
      @stops[0].atisstopid.should eql 'NNNNN'
      @stops[0].stopid.should eql 'string'


      @stops[1].description.should eql 'text description of the stop 2'
      @stops[1].area.should eql 'area description 2'
      @stops[1].lat.should eql '322'
      @stops[1].long.should eql '602'
      @stops[1].point.should eql '±dd.nnnnnn, ±ddd.nnnnnn'
      @stops[1].atisstopid.should eql 'SSSSS'
      @stops[1].stopid.should eql 'string 2'

    end

  end



























end

