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

  describe 'three itineraries, each with multiple service' do

    before do
      stub_atis_request.to_return( atis_response 'Plantrip', '1.27', '0', <<-BODY )
      <Tid></Tid>
      <Input>
        <Originlat>33.452082</Originlat>
        <Originlong>-112.074374</Originlong>
        <Originlandmarkid>7234</Originlandmarkid>
        <Origintext>CENTRAL STATION</Origintext>
        <Destinationlat>33.432254</Destinationlat>
        <Destinationlong>-111.904625</Destinationlong>
        <Destinationlandmarkid>7542</Destinationlandmarkid>
        <Destinationtext>TEMPE MARKETPLACE</Destinationtext>
        <Date>07/31/2012</Date>
        <Time>09:14 AM</Time>
        <Minimize>T</Minimize>
        <Accessible>N</Accessible>
        <Arrdep>D</Arrdep>
        <Walkspeed> 2.00 </Walkspeed>
        <Maxwalk>0.50</Maxwalk>
        <Walkorigin>0.50</Walkorigin>
        <Walkdestination>0.50</Walkdestination>
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
            <Ontime>0931</Ontime>
            <Onstopdata>
              <Description>VAN BUREN&#x2F;1ST AVE LIGHT RAIL STATION</Description>
              <Area>PH</Area>
              <Lat>33.452252</Lat>
              <Long>-112.075081</Long>
              <Time>0931</Time>
              <Date>07/31/12</Date>
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
              <Routeid>46860</Routeid>
              <Block>17027</Block>
              <Trip>3</Trip>
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
            <Offstop>MCCLINTOCK DR&#x2F;APACHE LIGHT RAIL STATION</Offstop>
            <Offtime>1007</Offtime>
            <Offstopdata>
              <Description>MCCLINTOCK DR&#x2F;APACHE LIGHT RAIL STATION</Description>
              <Area>TE</Area>
              <Lat>33.414688</Lat>
              <Long>-111.908882</Long>
              <Time>1007</Time>
              <Date>07/31/12</Date>
              <Atisstopid>10887</Atisstopid>
              <Stopid>10025</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>26</Stopseq>
              <Stopposition>O</Stopposition>
              <Heading>NB</Heading>
              <Side>Far</Side>
              <Accessible>N</Accessible>
            </Offstopdata>
          </Leg>
          <Leg>
            <Onwalkdist>0</Onwalkdist>
            <Onwalkdir> </Onwalkdir>
            <Onwalkhint>N</Onwalkhint>
            <Onstop>MCCLINTOCK DR &amp; APACHE BLVD</Onstop>
            <Ontime>1013</Ontime>
            <Onstopdata>
              <Description>MCCLINTOCK DR &amp; APACHE BLVD</Description>
              <Area>TE</Area>
              <Lat>33.414938</Lat>
              <Long>-111.909100</Long>
              <Time>1013</Time>
              <Date>07/31/12</Date>
              <Atisstopid>3431</Atisstopid>
              <Stopid>15090</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>32</Stopseq>
              <Stopposition>O</Stopposition>
              <Heading>NB</Heading>
              <Side>Far</Side>
              <Accessible>N</Accessible>
            </Onstopdata>
            <Service>
              <Route>81</Route>
              <Sign>81 Haydn&#x2F;Mclintk To Raintree&#x2F;Nrthsight</Sign>
              <Altsign></Altsign>
              <Direction>N</Direction>
              <Operator>VEOLIA-TEM</Operator>
              <Servicetype>W</Servicetype>
              <Routeid>38240</Routeid>
              <Block>4082</Block>
              <Trip>4</Trip>
              <Peak>N</Peak>
              <Routetype>B</Routetype>
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
            <Offstop>TEMPE MARKETPLACE</Offstop>
            <Offtime>1020</Offtime>
            <Offstopdata>
              <Description>TEMPE MARKETPLACE</Description>
              <Area>TE</Area>
              <Lat>33.432256</Lat>
              <Long>-111.904661</Long>
              <Time>1020</Time>
              <Date>07/31/12</Date>
              <Atisstopid>10453</Atisstopid>
              <Stopid>14167</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>36</Stopseq>
              <Stopposition> </Stopposition>
              <Heading> </Heading>
              <Side>unknown</Side>
              <Accessible>N</Accessible>
            </Offstopdata>
          </Leg>
        </Legs>
        <Finalwalk>0</Finalwalk>
        <Finalwalkdir> </Finalwalkdir>
        <Finalwalkhint>N</Finalwalkhint>
        <Transittime>49</Transittime>
        <Regularfare>3.50</Regularfare>
        <Reducedfare>1.70</Reducedfare>
        <Fareinfo>2|0|3.50|1.70~W|09:31 AM|10:07 AM|LTRL| |W|E|L|10|0|1944|3|46860|METRO|10880|11|10887|26|BUSFARE|0|0|0|R~T|10:13 AM|10:20 AM|81| |W|N|B|2|0|1609|4|38240|VEOLIA-TEM|3431|32|10453|36|BUSFARE|0|0|0|B~</Fareinfo>
        <Traceinfo>2|46860|11|26|38240|32|36</Traceinfo>
        <Exmodified>N</Exmodified>
        <Exmodids/>
        <Disttransit>12.39</Disttransit>
        <Distauto>12.63</Distauto>
        <Co2transit>5.437</Co2transit>
        <Co2auto>12.125</Co2auto>
      </Itin>
      <Itin>
        <Legs>
          <Leg>
            <Onwalkdist>0.21</Onwalkdist>
            <Onwalkdir>W</Onwalkdir>
            <Onwalkhint>Y</Onwalkhint>
            <Onstop>VAN BUREN&#x2F;1ST AVE LIGHT RAIL STATION</Onstop>
            <Ontime>0931</Ontime>
            <Onstopdata>
              <Description>VAN BUREN&#x2F;1ST AVE LIGHT RAIL STATION</Description>
              <Area>PH</Area>
              <Lat>33.452252</Lat>
              <Long>-112.075081</Long>
              <Time>0931</Time>
              <Date>07/31/12</Date>
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
              <Routeid>46860</Routeid>
              <Block>17027</Block>
              <Trip>3</Trip>
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
            <Offstop>VETERANS WAY&#x2F;COLLEGE LIGHT RAIL STATION</Offstop>
            <Offtime>0959</Offtime>
            <Offstopdata>
              <Description>VETERANS WAY&#x2F;COLLEGE LIGHT RAIL STATION</Description>
              <Area>TE</Area>
              <Lat>33.426222</Lat>
              <Long>-111.936477</Long>
              <Time>0959</Time>
              <Date>07/31/12</Date>
              <Atisstopid>10895</Atisstopid>
              <Stopid>10022</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>22</Stopseq>
              <Stopposition>O</Stopposition>
              <Heading>NB</Heading>
              <Side>Far</Side>
              <Accessible>N</Accessible>
            </Offstopdata>
          </Leg>
          <Leg>
            <Onwalkdist>0</Onwalkdist>
            <Onwalkdir> </Onwalkdir>
            <Onwalkhint>N</Onwalkhint>
            <Onstop>TEMPE TRANSIT CENTER NORTH SIDE</Onstop>
            <Ontime>1031</Ontime>
            <Onstopdata>
              <Description>TEMPE TRANSIT CENTER NORTH SIDE</Description>
              <Area>TE</Area>
              <Lat>33.425740</Lat>
              <Long>-111.935929</Long>
              <Time>1031</Time>
              <Date>07/31/12</Date>
              <Atisstopid>11042</Atisstopid>
              <Stopid>14163</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>42</Stopseq>
              <Stopposition> </Stopposition>
              <Heading> </Heading>
              <Side>unknown</Side>
              <Accessible>N</Accessible>
            </Onstopdata>
            <Service>
              <Route>62</Route>
              <Sign>62 Hardy&#x2F;Guadalupe To Tempe Marketplace</Sign>
              <Altsign></Altsign>
              <Direction>N</Direction>
              <Operator>VEOLIA-TEM</Operator>
              <Servicetype>W</Servicetype>
              <Routeid>37140</Routeid>
              <Block>4049</Block>
              <Trip>5</Trip>
              <Peak>N</Peak>
              <Routetype>B</Routetype>
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
            <Offstop>TEMPE MARKETPLACE</Offstop>
            <Offtime>1044</Offtime>
            <Offstopdata>
              <Description>TEMPE MARKETPLACE</Description>
              <Area>TE</Area>
              <Lat>33.432256</Lat>
              <Long>-111.904661</Long>
              <Time>1044</Time>
              <Date>07/31/12</Date>
              <Atisstopid>10453</Atisstopid>
              <Stopid>14167</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>51</Stopseq>
              <Stopposition> </Stopposition>
              <Heading> </Heading>
              <Side>unknown</Side>
              <Accessible>N</Accessible>
            </Offstopdata>
          </Leg>
        </Legs>
        <Finalwalk>0</Finalwalk>
        <Finalwalkdir> </Finalwalkdir>
        <Finalwalkhint>N</Finalwalkhint>
        <Transittime>73</Transittime>
        <Regularfare>3.50</Regularfare>
        <Reducedfare>1.70</Reducedfare>
        <Fareinfo>2|0|3.50|1.70~W|09:31 AM|09:59 AM|LTRL| |W|E|L|10|0|1944|3|46860|METRO|10880|11|10895|22|BUSFARE|0|0|0|R~T|10:31 AM|10:44 AM|62| |W|N|B|1|0|1279|5|37140|VEOLIA-TEM|11042|42|10453|51|BUSFARE|0|0|0|B~</Fareinfo>
        <Traceinfo>2|46860|11|22|37140|42|51</Traceinfo>
        <Exmodified>N</Exmodified>
        <Exmodids/>
        <Disttransit>11.82</Disttransit>
        <Distauto>12.08</Distauto>
        <Co2transit>5.520</Co2transit>
        <Co2auto>11.597</Co2auto>
      </Itin>
      <Itin>
        <Legs>
          <Leg>
            <Onwalkdist>0.21</Onwalkdist>
            <Onwalkdir>W</Onwalkdir>
            <Onwalkhint>Y</Onwalkhint>
            <Onstop>VAN BUREN&#x2F;1ST AVE LIGHT RAIL STATION</Onstop>
            <Ontime>0931</Ontime>
            <Onstopdata>
              <Description>VAN BUREN&#x2F;1ST AVE LIGHT RAIL STATION</Description>
              <Area>PH</Area>
              <Lat>33.452252</Lat>
              <Long>-112.075081</Long>
              <Time>0931</Time>
              <Date>07/31/12</Date>
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
              <Routeid>46860</Routeid>
              <Block>17027</Block>
              <Trip>3</Trip>
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
            <Offstop>MCCLINTOCK DR&#x2F;APACHE LIGHT RAIL STATION</Offstop>
            <Offtime>1007</Offtime>
            <Offstopdata>
              <Description>MCCLINTOCK DR&#x2F;APACHE LIGHT RAIL STATION</Description>
              <Area>TE</Area>
              <Lat>33.414688</Lat>
              <Long>-111.908882</Long>
              <Time>1007</Time>
              <Date>07/31/12</Date>
              <Atisstopid>10887</Atisstopid>
              <Stopid>10025</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>26</Stopseq>
              <Stopposition>O</Stopposition>
              <Heading>NB</Heading>
              <Side>Far</Side>
              <Accessible>N</Accessible>
            </Offstopdata>
          </Leg>
          <Leg>
            <Onwalkdist>0</Onwalkdist>
            <Onwalkdir> </Onwalkdir>
            <Onwalkhint>N</Onwalkhint>
            <Onstop>MCCLINTOCK DR &amp; APACHE BLVD</Onstop>
            <Ontime>1043</Ontime>
            <Onstopdata>
              <Description>MCCLINTOCK DR &amp; APACHE BLVD</Description>
              <Area>TE</Area>
              <Lat>33.414938</Lat>
              <Long>-111.909100</Long>
              <Time>1043</Time>
              <Date>07/31/12</Date>
              <Atisstopid>3431</Atisstopid>
              <Stopid>15090</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>32</Stopseq>
              <Stopposition>O</Stopposition>
              <Heading>NB</Heading>
              <Side>Far</Side>
              <Accessible>N</Accessible>
            </Onstopdata>
            <Service>
              <Route>81</Route>
              <Sign>81 Haydn&#x2F;Mclintk To Raintree&#x2F;Nrthsight</Sign>
              <Altsign></Altsign>
              <Direction>N</Direction>
              <Operator>VEOLIA-TEM</Operator>
              <Servicetype>W</Servicetype>
              <Routeid>38241</Routeid>
              <Block>4085</Block>
              <Trip>4</Trip>
              <Peak>N</Peak>
              <Routetype>B</Routetype>
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
            <Offstop>TEMPE MARKETPLACE</Offstop>
            <Offtime>1050</Offtime>
            <Offstopdata>
              <Description>TEMPE MARKETPLACE</Description>
              <Area>TE</Area>
              <Lat>33.432256</Lat>
              <Long>-111.904661</Long>
              <Time>1050</Time>
              <Date>07/31/12</Date>
              <Atisstopid>10453</Atisstopid>
              <Stopid>14167</Stopid>
              <Stopstatustype>N</Stopstatustype>
              <Stopseq>36</Stopseq>
              <Stopposition> </Stopposition>
              <Heading> </Heading>
              <Side>unknown</Side>
              <Accessible>N</Accessible>
            </Offstopdata>
          </Leg>
        </Legs>
        <Finalwalk>0</Finalwalk>
        <Finalwalkdir> </Finalwalkdir>
        <Finalwalkhint>N</Finalwalkhint>
        <Transittime>79</Transittime>
        <Regularfare>3.50</Regularfare>
        <Reducedfare>1.70</Reducedfare>
        <Fareinfo>2|0|3.50|1.70~W|09:31 AM|10:07 AM|LTRL| |W|E|L|10|0|1944|3|46860|METRO|10880|11|10887|26|BUSFARE|0|0|0|R~T|10:43 AM|10:50 AM|81| |W|N|B|2|0|1610|4|38241|VEOLIA-TEM|3431|32|10453|36|BUSFARE|0|0|0|B~</Fareinfo>
        <Traceinfo>2|46860|11|26|38241|32|36</Traceinfo>
        <Exmodified>N</Exmodified>
        <Exmodids/>
        <Disttransit>12.39</Disttransit>
        <Distauto>12.63</Distauto>
        <Co2transit>5.437</Co2transit>
        <Co2auto>12.125</Co2auto>
      </Itin>
    BODY

      @itineraries = AtisItinerary.where(
        :date => '07/31/2012', :time => '0914', :minimize => 'T',
        :origin_lat => '33.452082', :origin_long => '-112.074374',
        :destination_lat => '33.432254', :destination_long => '-111.904625' )
    end

    describe '#where' do

      it 'only makes one request' do
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do
        an_atis_request_for('Plantrip',
          'Date' => '07/31/2012', 'Time' => '0914', 'Minimize' => 'T',
          'Originlat' => '33.452082', 'Originlong' => '-112.074374',
          'Destinationlat' => '33.432254', 'Destinationlong' => '-111.904625'
           ).should have_been_made
      end

      it 'returns three itineraries' do
        @itineraries.should have(3).item
        @itineraries.each { |itin| itin.should be_a_kind_of AtisItinerary }
      end

    end

  end

end

