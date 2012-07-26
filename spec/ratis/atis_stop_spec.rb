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

end

