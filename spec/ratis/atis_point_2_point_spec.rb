require 'spec_helper'

describe Ratis::Point2Point do

  describe 'Routesonly => Y' do

    describe '#where' do

      describe 'services from origin to destination' do
        before do
          stub_atis_request.to_return( atis_response 'Point2point', '1.3', '0', <<-BODY )
          <Routes>
            <Service>
              <Route>10</Route>
              <Direction>W</Direction>
              <Servicetype>S</Servicetype>
              <Signage>10 Roosvlt&#x2F;Grnt To 35Av&#x2F;Lwr Buckeye</Signage>
              <Routetype>B</Routetype>
            </Service>
            <Service>
              <Route>3</Route>
              <Direction>E</Direction>
              <Servicetype>S</Servicetype>
              <Signage>3 VAN BUREN East to 48th St.</Signage>
              <Routetype>B</Routetype>
            </Service>
          </Routes>
          BODY

          @services = Ratis::Point2Point.where(:routes_only => true,
            :origin_lat => 33.451929, :origin_long => -112.07457,
            :destination_lat => 33.44641, :destination_long => -112.06987,
            :date => '08/04/12', :start_time => '0900', :end_time => '1100')
        end

        it 'only makes one request' do
          an_atis_request.should have_been_made.times 1
        end

        it 'requests the correct SOAP action' do
          an_atis_request_for('Point2point',
            'Originlat' => '33.451929', 'Originlong' => '-112.07457',
            'Destinationlat' => '33.44641', 'Destinationlong' => '-112.06987',
            'Date' => '08/04/12', 'Starttime' => '0900', 'Endtime' => '1100',
            'Routesonly' => 'Y'
             ).should have_been_made
        end

        it 'gets matched services' do
          @services.should have(2).items
        end

        it 'parses out service fields' do
          service = @services.first
          service.route.should eql '10'
          service.direction.should eql 'W'
          service.service_type.should eql 'S'
          service.signage.should eql '10 Roosvlt/Grnt To 35Av/Lwr Buckeye'
          service.route_type.should eql 'B'
        end
      end

    end
  end

  describe 'Routesonly => N' do

    describe '#where' do

      before do
        stub_atis_request.to_return( atis_response 'Point2point', '1.3', '0', <<-BODY )
        <Groups>
          <Group>
            <Onstop>
              <Description>VAN BUREN&#x2F;1ST AVE LIGHT RAIL STATION</Description>
              <Lat>33.452252</Lat>
              <Long>-112.075081</Long>
              <Atisstopid>10880</Atisstopid>
              <Onwalkdist>0.077</Onwalkdist>
              <Onwalkdir>NW</Onwalkdir>
              <Onwalkhint>N</Onwalkhint>
            </Onstop>
            <Offstop>
              <Description>3RD STREET&#x2F;JEFFERSON LIGHT RAIL STATION</Description>
              <Lat>33.446270</Lat>
              <Long>-112.069777</Long>
              <Atisstopid>10892</Atisstopid>
              <Offstopwalk>0.016</Offstopwalk>
              <Offstopwalkdir>SE</Offstopwalkdir>
              <Offstopwalkhint>N</Offstopwalkhint>
            </Offstop>
            <Trips>
              <Trip>
                <Ontime>09:07 AM</Ontime>
                <Offtime>09:11 AM</Offtime>
                <Service>
                  <Route>LTRL</Route>
                  <Direction>E</Direction>
                  <Servicetype>S</Servicetype>
                  <Signage>Metro light rail To Sycamore&#x2F;Main</Signage>
                  <Routetype>L</Routetype>
                  <Exception>N</Exception>
                </Service>
              </Trip>
              <Trip>
                <Ontime>09:22 AM</Ontime>
                <Offtime>09:26 AM</Offtime>
                <Service>
                  <Route>LTRL</Route>
                  <Direction>E</Direction>
                  <Servicetype>S</Servicetype>
                  <Signage>Metro light rail To Sycamore&#x2F;Main</Signage>
                  <Routetype>L</Routetype>
                  <Exception>N</Exception>
                </Service>
              </Trip>
            </Trips>
          </Group>
          <Group>
            <Onstop>
              <Description>1ST AVE &amp; VAN BUREN ST</Description>
              <Lat>33.451748</Lat>
              <Long>-112.075169</Long>
              <Atisstopid>3795</Atisstopid>
              <Onwalkdist>0.046</Onwalkdist>
              <Onwalkdir>W</Onwalkdir>
              <Onwalkhint>N</Onwalkhint>
            </Onstop>
            <Offstop>
              <Description>1ST AVE &amp; JEFFERSON ST</Description>
              <Lat>33.446947</Lat>
              <Long>-112.075255</Long>
              <Atisstopid>9959</Atisstopid>
              <Offstopwalk>0.327</Offstopwalk>
              <Offstopwalkdir>W</Offstopwalkdir>
              <Offstopwalkhint>N</Offstopwalkhint>
            </Offstop>
            <Trips>
              <Trip>
                <Ontime>09:00 AM</Ontime>
                <Offtime>09:01 AM</Offtime>
                <Service>
                  <Route>10</Route>
                  <Direction>W</Direction>
                  <Servicetype>S</Servicetype>
                  <Signage>10 Roosvlt&#x2F;Grnt To 35Av&#x2F;Lwr Buckeye</Signage>
                  <Routetype>B</Routetype>
                  <Exception>N</Exception>
                </Service>
              </Trip>
              <Trip>
                <Ontime>09:10 AM</Ontime>
                <Offtime>09:11 AM</Offtime>
                <Service>
                  <Route>0</Route>
                  <Direction>S</Direction>
                  <Servicetype>S</Servicetype>
                  <Signage>0 Central South To Baseline Rd</Signage>
                  <Routetype>B</Routetype>
                  <Exception>N</Exception>
                </Service>
              </Trip>
              <Trip>
                <Ontime>09:40 AM</Ontime>
                <Offtime>09:41 AM</Offtime>
                <Service>
                  <Route>0</Route>
                  <Direction>S</Direction>
                  <Servicetype>S</Servicetype>
                  <Signage>0 CENTRAL South to Dobbins</Signage>
                  <Routetype>B</Routetype>
                  <Exception>N</Exception>
                </Service>
              </Trip>
            </Trips>
          </Group>
        </Groups>
        BODY

        @schedule = Ratis::Point2Point.where(:routes_only => false,
          :origin_lat => 33.451929, :origin_long => -112.07457,
          :destination_lat => 33.44641, :destination_long => -112.06987,
          :date => '08/04/12', :start_time => '0900', :end_time => '1100')
      end

      it 'only makes one request' do
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do an_atis_request_for('Point2point',
          'Originlat' => '33.451929', 'Originlong' => '-112.07457',
          'Destinationlat' => '33.44641', 'Destinationlong' => '-112.06987',
          'Date' => '08/04/12', 'Starttime' => '0900', 'Endtime' => '1100',
          'Routesonly' => 'N'
           ).should have_been_made
      end

      it 'gets the groups' do
        @schedule.should have(2).groups
        @schedule.groups.first.should be_kind_of AtisScheduleGroup
        @schedule.groups.last.should be_kind_of AtisScheduleGroup
      end

      it 'gets the trips within each group' do
        @schedule.groups.first.should have(2).trips
        @schedule.groups.last.should have(3).trips
      end

      it 'parses out the on stop fields' do
        group = @schedule.groups.first
        on_stop = group.on_stop

        on_stop.should be_kind_of Ratis::Stop

        on_stop.description.should eql 'VAN BUREN/1ST AVE LIGHT RAIL STATION'
        on_stop.latitude.should eql 33.452252
        on_stop.longitude.should eql -112.075081
        on_stop.atis_stop_id.should eql 10880
        on_stop.walk_dist.should eql 0.077
        on_stop.walk_dir.should eql 'NW'
        on_stop.walk_hint.should eql 'N'
      end

      it 'parses out the off stop fields' do
        group = @schedule.groups.first
        off_stop = group.off_stop

        off_stop.description.should eql '3RD STREET/JEFFERSON LIGHT RAIL STATION'
        off_stop.latitude.should eql 33.446270
        off_stop.longitude.should eql -112.069777
        off_stop.atis_stop_id.should eql 10892
        off_stop.walk_dist.should eql 0.016
        off_stop.walk_dir.should eql 'SE'
        off_stop.walk_hint.should eql 'N'
      end

      it 'parses out the trip' do
        group = @schedule.groups.first
        trip = group.trips.first

        trip.should be_kind_of AtisScheduleTrip
        trip.on_time.should eql '09:07 AM'
        trip.off_time.should eql '09:11 AM'
      end

      it 'parses out the service' do
        group = @schedule.groups.first
        service = group.trips.first.service

        service.should be_kind_of AtisService
        service.route.should eql 'LTRL'
        service.direction.should eql 'E'
        service.service_type.should eql 'S'
        service.signage.should eql 'Metro light rail To Sycamore/Main'
        service.route_type.should eql 'L'
        service.exception.should eql 'N'
      end

    end
  end

end

