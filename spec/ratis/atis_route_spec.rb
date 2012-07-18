require 'spec_helper'

describe AtisRoute do

  describe '#all' do

    before do
      stub_atis_request.to_return( atis_response 'Allroutes', '1.5', '0', <<-BODY )
        <Routes>
          0, N, S
          1, E, W
        </Routes>
      BODY

      @all_routes = AtisRoute.all
    end

    it 'only makes one request' do
      an_atis_request.should have_been_made.times 1
    end

    it 'gets all routes' do
      @all_routes.should have(2).items
    end

    it 'gets all route directions' do
      @all_routes.each do |route|
        route.should have(2).directions
      end
    end

  end

  it 'should initialize' do
    route = AtisRoute.new '123', ['N', 'S']

    route.short_name.should eql '123'
    route.directions.should eql ['N', 'S']
  end

end

