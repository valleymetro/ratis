require 'spec_helper'

describe AtisLandmarkCategory do

  before do
    stub_atis_request.to_return( atis_response 'Getcategories', '1.1', '0', <<-BODY )
    <Types>
      <Typeinfo>
        <Type>AIRPORT</Type>
        <Description>AIRPT</Description>
      </Typeinfo>
      <Typeinfo>
        <Type>CASINO</Type>
        <Description>CAS</Description>
      </Typeinfo>
      <Typeinfo>
        <Type>CEMETARIES</Type>
        <Description>CEM</Description>
      </Typeinfo>
    </Types>
    BODY

    @landmark_categories = AtisLandmarkCategory.all
  end

  it 'only makes one request' do
    an_atis_request.should have_been_made.times 1
  end

  it 'requests the correct SOAP action' do
    an_atis_request_for('Getcategories').should have_been_made
  end

  it 'should return all landmark categories' do
    @landmark_categories.should have(3).items

    @landmark_categories[0].type.should eql 'AIRPORT'
    @landmark_categories[0].description.should eql 'AIRPT'
    @landmark_categories[1].type.should eql 'CASINO'
    @landmark_categories[1].description.should eql 'CAS'
    @landmark_categories[2].type.should eql 'CEMETARIES'
    @landmark_categories[2].description.should eql 'CEM'
  end

end

