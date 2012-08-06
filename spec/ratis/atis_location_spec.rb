require 'spec_helper'

describe AtisLocation do

  describe 'Intersection or Stop' do
    pending 'needs implementation'
  end

  describe 'Landmark' do

    before do
      stub_atis_request.to_return( atis_response 'Locate', '1.12', 'ok', <<-BODY )
      <Projection>SP</Projection>
      <Locationtype>L</Locationtype>
      <Location>
              <Name>CENTRAL STATION</Name>
              <Area>Phoenix</Area>
              <Areacode>PH</Areacode>
              <Region>1</Region>
              <Zipname></Zipname>
              <Latitude>33.452082</Latitude>
              <Longitude>-112.074374</Longitude>
              <Landmarkid>7234</Landmarkid>
              <Islocality>N</Islocality>
      </Location>
      BODY

      @locations = AtisLocation.where :location => "Central Station", :media => 'a', :max_answers => 3
      @first_location = @locations.first
    end

    describe '#where' do

      it 'only makes one request' do
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do
        an_atis_request_for('Locate', 'Location' => 'Central Station', 'Media' => 'A', 'Maxanswers' => '3').should have_been_made
      end

      it 'returns the single locations' do
        @locations.should have(1).item
      end

      it 'parses out fields correctly' do
        @first_location.name.should eql 'CENTRAL STATION'
        @first_location.area.should eql 'Phoenix'
        @first_location.response.should eql 'ok'
        @first_location.areacode.should eql 'PH'
        @first_location.latitude.should eql '33.452082'
        @first_location.longitude.should eql '-112.074374'
        @first_location.landmark_id.should eql '7234'
        @first_location.address.should eql ''
        @first_location.startaddr.should eql ''
        @first_location.endaddr.should eql ''
        @first_location.address_string.should eql 'CENTRAL STATION (in Phoenix)'
      end

    end

  end

  describe 'Address with house number match' do
    pending 'needs implementation'
  end

  describe 'Address without house number match' do

    before do
      stub_atis_request.to_return( atis_response 'Locate', '1.12', 'ambig', <<-BODY )
      <Locationtype>A</Locationtype>
      <Projection>SP</Projection>
      <Location>
        <Name>W PENNSYLVANIA AVE</Name>
        <Area>Youngtown</Area>
        <Areacode>YG</Areacode>
        <Region>1</Region>
        <Zipname>85363 - Youngtown</Zipname>
        <Latitude>33.5811205</Latitude>
        <Longitude>-112.2989325</Longitude>
        <Landmarkid>0</Landmarkid>
        <Startaddr>11105</Startaddr>
        <Endaddr>11111</Endaddr>
        <Startlatitude>33.581130</Startlatitude>
        <Startlongitude>-112.298791</Startlongitude>
        <Endlatitude>33.581111</Endlatitude>
        <Endlongitude>-112.299074</Endlongitude>
      </Location>
      <Location>
        <Name>W PENNSYLVANIA AVE</Name>
        <Area>Youngtown</Area>
        <Areacode>YG</Areacode>
        <Region>1</Region>
        <Zipname>85363 - Youngtown</Zipname>
        <Latitude>33.581082</Latitude>
        <Longitude>-112.2991235</Longitude>
        <Landmarkid>0</Landmarkid>
        <Startaddr>11109</Startaddr>
        <Endaddr>11113</Endaddr>
        <Startlatitude>33.581111</Startlatitude>
        <Startlongitude>-112.299074</Startlongitude>
        <Endlatitude>33.581053</Endlatitude>
        <Endlongitude>-112.299173</Endlongitude>
      </Location>
      BODY

      @locations = AtisLocation.where :location => '1600 Pennsylvania Ave', :media => 'W', :max_answers => 1000
      @first_location = @locations.first
    end

    describe '#where' do

      it 'only makes one request' do
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do
        an_atis_request_for('Locate', 'Location' => '1600 Pennsylvania Ave', 'Media' => 'W', 'Maxanswers' => '1000').should have_been_made
      end

      it 'returns multiple locations' do
        @locations.should have(2).items
      end

      it 'parses out fields correctly' do
        @first_location.name.should eql 'W PENNSYLVANIA AVE'
        @first_location.area.should eql 'Youngtown'
        @first_location.response.should eql 'ambig'
        @first_location.areacode.should eql 'YG'
        @first_location.latitude.should eql '33.5811205'
        @first_location.longitude.should eql '-112.2989325'
        @first_location.landmark_id.should eql '0'
        @first_location.address.should eql ''
        @first_location.startaddr.should eql '11105'
        @first_location.endaddr.should eql '11111'
        @first_location.address_string.should eql '11105 - 11111 W PENNSYLVANIA AVE (in Youngtown)'
      end

    end

    describe '#to_a' do
      it 'returns lat, lon, name and landmark_id' do
        @first_location.to_a.should eql ['33.5811205', '-112.2989325', 'W PENNSYLVANIA AVE', '0']
      end
    end

    describe '#to_hash' do
      it 'returns a subset of AtisLocation params' do
        hash = {
          :latitude   => '33.5811205',
          :longitude  => '-112.2989325',
          :name       => 'W PENNSYLVANIA AVE',
          :area       => 'Youngtown',
          :address    => '',
          :startaddr  => '11105',
          :endaddr    => '11111',
          :address_string => '11105 - 11111 W PENNSYLVANIA AVE (in Youngtown)',
          :landmark_id => '0' }

        HashDiff.diff(@first_location.to_hash, hash).should eql []
      end

    end

  end

  describe '#where' do

    it 'defaults media to W' do
      stub_atis_request.to_return( atis_response 'Locate', '1.12', 'ok', <<-BODY )
      <Location>
        <Name>Some place</Name>
      </Location>
      BODY

      AtisLocation.where :location => 'Some place', :max_answers => 1000
      an_atis_request_for('Locate', 'Location' => 'Some place', 'Media' => 'W', 'Maxanswers' => '1000').should have_been_made
    end

    it 'requires a valid media' do
      expect do
        AtisLocation.where :location => 'Some place', :media => 'XYZZY'
      end.to raise_error ArgumentError, 'You must provide media of A|W|I'
    end

    it 'defaults max_answers to 20' do
      stub_atis_request.to_return( atis_response 'Locate', '1.12', 'ok', <<-BODY )
      <Location>
        <Name>Some place</Name>
      </Location>
      BODY

      AtisLocation.where :location => 'Some place', :media => 'W'
      an_atis_request_for('Locate', 'Location' => 'Some place', 'Media' => 'W', 'Maxanswers' => '20').should have_been_made
    end

    it 'requires a numeric max_answers' do
      expect do
        AtisLocation.where :location => 'Some place', :max_answers => 'not a number'
      end.to raise_error ArgumentError, 'You must provide a numeric max_answers'
    end

  end

end

