require 'spec_helper'

describe Ratis::Area do

  before do
    stub_atis_request.to_return( atis_response 'Getareas', '1.0', '0', <<-BODY )
      <Areainfo>
        <Area>Area1</Area>
        <Description>D1</Description> 
      </Areainfo>
      <Areainfo>
        <Area>Area2</Area>
        <Description>D2</Description>
      </Areainfo>
    BODY

    @areas = Ratis::Area.all
  end

  it 'only makes one request' do
    an_atis_request.should have_been_made.times 1
  end

  it 'requests the correct SOAP action' do
    an_atis_request_for('Getareas').should have_been_made
  end

  it 'should return all areas' do
    @areas.should have(2).items

    @areas[0].area.should eql 'Area1'
    @areas[0].description.should eql 'D1'
    @areas[1].area.should eql 'Area2'
    @areas[1].description.should eql 'D2'
  end

end

