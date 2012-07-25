require 'spec_helper'

describe AtisLandmark do

  before do
    stub_atis_request.to_return( atis_response 'Getlandmarks', '1.4', '0', <<-BODY )
    <Landmarks>
      <Landmark>
        <Id>5007</Id>
        <Verbose>FALCON FIELD AIRPORT</Verbose>
        <Location>4800 E. FALCON DR.</Location>
        <Area>ME</Area>
        <Latitude>33.456119</Latitude>
        <Longitude>-111.728010</Longitude>
        <Locality>N</Locality>
        <Type>AIRPT</Type>
        <Map_level>3</Map_level>
        <Notes> Hours of Operation: </Notes>
        <Zipcode>85215</Zipcode>
      </Landmark>
      <Landmark>
        <Id>5009</Id>
        <Verbose>SKY HARBOR AIRPORT TERMINAL 4 WB</Verbose>
        <Location>3700 E SKY HARBOR BLVD</Location>
        <Area>PH</Area>
        <Latitude>33.434520</Latitude>
        <Longitude>-111.996145</Longitude>
        <Locality>N</Locality>
        <Type>AIRPT</Type>
        <Map_level>3</Map_level>
        <Notes> Hours of Operation: !!!!!!!!24 hours</Notes>
        <Zipcode>99999</Zipcode>
      </Landmark>
    </Landmarks>
    BODY

    @landmarks = AtisLandmark.where type: :all
  end

  it 'only makes one request' do
    an_atis_request.should have_been_made.times 1
  end

  it 'requests the correct SOAP action' do
    an_atis_request_for('Getlandmarks', 'Type' => 'ALL').should have_been_made
  end

  it 'should return all landmarks' do
    @landmarks.should have(2).items

    @landmarks[0].type.should eql 'AIRPT'
    @landmarks[0].verbose.should eql 'FALCON FIELD AIRPORT'
    @landmarks[0].location.should eql '4800 E. FALCON DR.'
    @landmarks[0].locality.should eql 'N'

    @landmarks[1].type.should eql 'AIRPT'
    @landmarks[1].verbose.should eql 'SKY HARBOR AIRPORT TERMINAL 4 WB'
    @landmarks[1].location.should eql '3700 E SKY HARBOR BLVD'
    @landmarks[1].locality.should eql 'N'
  end

end

