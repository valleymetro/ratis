require 'spec_helper'

describe AtisRoute do
  it 'should initialize' do
    route = AtisRoute.new '123', ['N', 'S']

    route.short_name.should eql '123'
    route.directions.should eql ['N', 'S']
  end

end

