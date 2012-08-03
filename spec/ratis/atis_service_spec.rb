require 'spec_helper'

describe AtisService do

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

        @services = AtisService.where(
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

