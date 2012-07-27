require 'spec_helper'

describe AtisItinerary do

  describe 'single itinerary, single service' do

    before do
      stub_atis_request.to_return( atis_response 'Plantrip', '1.27', '0', <<-BODY )
      <Input>
        <Originlat>33.452082</Originlat>
        <Originlong>-112.074374</Originlong>
        <Originlandmarkid>0</Originlandmarkid>
        <Origintext>Origin</Origintext>
        <Destinationlat>33.446347</Destinationlat>
        <Destinationlong>-112.068689</Destinationlong>
        <Destinationlandmarkid>0</Destinationlandmarkid>
        <Destinationtext>Destination</Destinationtext>
        <Date>07/26/2012</Date>
        <Time>06:43 PM</Time>
        <Minimize>T</Minimize>
        <Accessible>N</Accessible>
        <Arrdep>D</Arrdep>
        <Walkspeed> 2.00 </Walkspeed>
        <Maxwalk>0.4</Maxwalk>
        <Walkorigin>0.4</Walkorigin>
        <Walkdestination>0.4</Walkdestination>
      </Input>
      <Lesserttime>
        <Time/>
        <Arrdep/>
      </Lesserttime>
      <Walkable>N</Walkable>
      <Walkadjust>0</Walkadjust>
      <Itin>
        <Legs>
          <Leg>
            <Onwalkdist>0.21</Onwalkdist>
            <Onwalkdir>W</Onwalkdir>
            <Onwalkhint>Y</Onwalkhint>
            <Onstop>VAN BUREN&#x2F;1ST AVE LIGHT RAIL STATION</Onstop>
            <Ontime>1859</Ontime>
            <Onstopdata>
              <Description>VAN BUREN&#x2F;1ST AVE LIGHT RAIL STATION</Description>
              <Area>PH</Area>
              <Lat>33.452252</Lat>
              <Long>-112.075081</Long>
              <Time>1859</Time>
              <Date>07/26/12</Date>
              <Atisstopid>10880</Atisstopid>
              <Stopid>10012</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>11</Stopseq>
              <Stopposition>O</Stopposition>
              <Heading>NB</Heading>
              <Side>Far</Side>
              <Accessible>N</Accessible>
            </Onstopdata>
            <Service>
              <Route>LTRL</Route>
              <Sign>Metro light rail To Sycamore&#x2F;Main</Sign>
              <Altsign></Altsign>
              <Direction>E</Direction>
              <Operator>METRO</Operator>
              <Servicetype>W</Servicetype>
              <Routeid>46880</Routeid>
              <Block>17074</Block>
              <Trip>14</Trip>
              <Peak>N</Peak>
              <Routetype>L</Routetype>
              <Statustype>N</Statustype>
              <Adherence>0</Adherence>
              <Polltime></Polltime>
              <Lat>0.000000</Lat>
              <Long>0.000000</Long>
              <Vehicle></Vehicle>
              <Patternorigin></Patternorigin>
              <Patterndestination></Patterndestination>
              <Exception>N</Exception>
              <Statusid>0</Statusid>
            </Service>
            <Fare>
              <Onfarezone>0</Onfarezone>
              <Offfarezone>0</Offfarezone>
              <Legregularfare>1.75</Legregularfare>
              <Legregularfarexfer>0.00</Legregularfarexfer>
              <Legreducedfare>0.85</Legreducedfare>
              <Legreducedfarexfer>0.00</Legreducedfarexfer>
            </Fare>
            <Offstop>3RD STREET&#x2F;JEFFERSON LIGHT RAIL STATION</Offstop>
            <Offtime>1903</Offtime>
            <Offstopdata>
              <Description>3RD STREET&#x2F;JEFFERSON LIGHT RAIL STATION</Description>
              <Area>PH</Area>
              <Lat>33.446270</Lat>
              <Long>-112.069777</Long>
              <Time>1903</Time>
              <Date>07/26/12</Date>
              <Atisstopid>10892</Atisstopid>
              <Stopid>10014</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>13</Stopseq>
              <Stopposition>O</Stopposition>
              <Heading>NB</Heading>
              <Side>Far</Side>
              <Accessible>N</Accessible>
            </Offstopdata>
          </Leg>
        </Legs>
        <Finalwalk>0.07</Finalwalk>
        <Finalwalkdir>E</Finalwalkdir>
        <Finalwalkhint>Y</Finalwalkhint>
        <Transittime>4</Transittime>
        <Regularfare>1.75</Regularfare>
        <Reducedfare>0.85</Reducedfare>
        <Fareinfo>1|0|1.75|0.85~W|06:59 PM|07:03 PM|LTRL| |W|E|L|12|0|1956|14|46880|METRO|10880|11|10892|13|BUSFARE|0|0|0|R~</Fareinfo>
        <Traceinfo>1|46880|11|13</Traceinfo>
        <Exmodified>N</Exmodified>
        <Exmodids/>
        <Disttransit> 0.63</Disttransit>
        <Distauto> 0.92</Distauto>
        <Co2transit>0.260</Co2transit>
        <Co2auto>0.881</Co2auto>
      </Itin>
      BODY

      @itineraries = AtisItinerary.where(
        :date => '07/26/2012', :time => '1843', :minimize => 'T',
        :origin_lat => '33.452082', :origin_long => '-112.074374',
        :destination_lat => '33.446347', :destination_long => '-112.068689' )
    end

    describe '#where' do

      it 'only makes one request' do
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do
        an_atis_request_for('Plantrip',
          'Date' => '07/26/2012', 'Time' => '1843', 'Minimize' => 'T',
          'Originlat' => '33.452082', 'Originlong' => '-112.074374',
          'Destinationlat' => '33.446347', 'Destinationlong' => '-112.068689'
           ).should have_been_made
      end

      it 'returns one itinerary' do
        @itineraries.should have(1).item
        @itineraries.first.should be_a_kind_of AtisItinerary
      end

    end

    describe '#legs' do

      it 'returns one leg' do
        @itineraries.first.legs.should have(1).item
        @itineraries.first.legs.first.should_not be_nil
      end

    end

    it 'marshalls the members to their correct type' do
      itinerary = @itineraries.first
      itinerary.co2_auto = 0.881
      itinerary.co2_transit = 0.260
      itinerary.final_walk_dir = 'E'
      itinerary.reduced_fare = 0.85
      itinerary.regular_fare = 1.75
      itinerary.transit_time = 4
    end

  end

  describe 'multiple itinerary, multiple service' do
    pending 'needs implementation'
  end

end

