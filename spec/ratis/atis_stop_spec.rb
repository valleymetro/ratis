require 'spec_helper'

describe AtisStop do

  describe '#closest' do

    before do
      stub_atis_request.to_return atis_response 'Closeststop', '1.11', '0', <<-BODY
      <Input>
        <Locationlat>33.4556</Locationlat>
        <Locationlong>-112.071807</Locationlong>
        <Locationtext>Text of the location as "located" using the locate message</Locationtext>
        <Numstops>15</Numstops>
        <Distance>0</Distance>
        <Accessible>Y</Accessible>
        <Xmode> BCXTFRSLK123 </Xmode>
      </Input>
      <Stops>
        <Stop>
          <Walkdist>0.1</Walkdist>
          <Description>text description stop one</Description>
          <Stopid>12345</Stopid>
          <Atisstopid>66666</Atisstopid>
          <Lat>33.4576</Lat>
          <Long>-112.071507</Long>
          <Walkdir>NE</Walkdir>
          <Stopposition>N</Stopposition>
          <Heading>NB</Heading>
          <Side>Far</Side>
          <Routedirs>
            <Routedir>0-N</Routedir>
          </Routedirs>
        </Stop>
        <Stop>
          <Walkdist>0.5</Walkdist>
          <Description>text description of stop two</Description>
          <Stopid>12345</Stopid>
          <Atisstopid>66666</Atisstopid>
          <Lat>33.4356</Lat>
          <Long>-112.071607</Long>
          <Walkdir>S</Walkdir>
          <Stopposition>S</Stopposition>
          <Heading>SB</Heading>
          <Side>Near</Side>
          <Routedirs>
            <Routedir>6-W</Routedir>
          </Routedirs>
        </Stop>
      </Stops>
      BODY

      @stops = AtisStop.closest :latitude => '33.4556', :longitude => '-112.071807', :location_text => 'some location text', :num_stops => 15
      @first_stop = @stops.first
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'requests the correct SOAP action' do
      an_atis_request_for(
        'Closeststop',
        'Locationlat' => '33.4556', 'Locationlong' => '-112.071807',
        'Locationtext' => 'some location text',
        'Numstops' => '15'
      ).should have_been_made
    end

    it 'returns multiple locations' do
      @stops.should have(2).items
    end

    it 'ignores a <Stop> without a blank <Description>' do
      pending 'not sure if this is the correct behaviour'
    end

    it 'parses out fields correctly' do
      @first_stop.walkdist.should eql '0.1'
      @first_stop.description.should eql 'text description stop one'
      @first_stop.stopid.should eql '12345'
      @first_stop.atisstopid.should eql '66666'
      @first_stop.latitude.should eql '33.4576'
      @first_stop.longitude.should eql '-112.071507'
      @first_stop.walkdir.should eql 'NE'
      @first_stop.side.should eql 'Far'
      @first_stop.heading.should eql 'NB'
      @first_stop.stopposition.should eql 'N'
      @first_stop.routedir.should eql '0-N'
    end

  end

  describe '#route_stops' do

    before do
      stub_atis_request.to_return atis_response 'Routestops', '1.0', '0', <<-BODY
      <Route>0</Route>
      <Direction>N</Direction>
      <Stops>
        <Stop>
          <Description>CENTRAL AVE &amp; ADAMS ST</Description>
          <Area>Phoenix</Area>
          <Atisstopid>2854</Atisstopid>
          <Stopid>10075</Stopid>
          <Alphaseq>0</Alphaseq>
          <Stopseq>25</Stopseq>
          <Point>33.448994,-112.073813</Point>
        </Stop>
        <Stop>
          <Description>CENTRAL AVE &amp; ALICE AVE --NORTHBOUND</Description>
          <Area>Phoenix</Area>
          <Atisstopid>2808</Atisstopid>
          <Stopid>10117</Stopid>
          <Alphaseq>1</Alphaseq>
          <Stopseq>62</Stopseq>
          <Point>33.564494,-112.073877</Point>
        </Stop>
        <Stop>
          <Description>CENTRAL AVE &amp; ALTA VISTA RD</Description>
          <Area>Phoenix</Area>
          <Atisstopid>3313</Atisstopid>
          <Stopid>10057</Stopid>
          <Alphaseq>2</Alphaseq>
          <Stopseq>7</Stopseq>
          <Point>33.388694,-112.073290</Point>
        </Stop>
      </Stops>
      BODY

      @stops = AtisStop.route_stops :route => '0', :direction => :n, :order => :a
      @first_stop = @stops.first
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'requests the correct SOAP action' do
      an_atis_request_for(
        'Routestops',
        'Route' => '0', 'Direction' => 'N', 'Order' => 'A'
      ).should have_been_made
    end

    it 'returns multiple stops' do
      @stops.should have(3).items
    end

    it 'parses out fields correctly' do
      @first_stop.description.should eql 'CENTRAL AVE & ADAMS ST'
      @first_stop.area.should eql 'Phoenix'
      @first_stop.atisstopid.should eql '2854'
      @first_stop.stop_seq.should eql '25'
      @first_stop.latitude.should eql '33.448994'
      @first_stop.longitude.should eql '-112.073813'
    end

  end

end

