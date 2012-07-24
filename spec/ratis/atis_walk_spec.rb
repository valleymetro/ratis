require 'spec_helper'

describe 'AtisWalk' do

  describe 'walk to the pub' do

    before do
      stub_atis_request.to_return( atis_response 'Walkstop', '1.2', '0', <<-BODY )
      <Walkinfo>
        <Walkdistance>1.2</Walkdistance>
        <Walkunits>miles</Walkunits>
        <Walktime>22</Walktime>
      </Walkinfo>
      <Starttext>text of the starting point of the walk</Starttext>
      <Endtext>text of the ending point of the walk</Endtext>
      <Walk>
        <Leg>Do some walking</Leg>
        <Leg>Walk some more</Leg>
      </Walk>
      <Walkpoints>
        <Walkpoint>33.45455, -112.07064</Walkpoint>
        <Walkpoint>33.45454, -112.071263</Walkpoint>
        <Walkpoint>33.45453, -112.07256</Walkpoint>
        <Walkpoint>33.45586, -112.07255</Walkpoint>
      </Walkpoints>
      BODY

      @walk = AtisWalk.walk_stop start_latitude: '33.45455', start_longitude: '-112.07064', end_latitude: '33.45586', end_longitude: '-112.07255'
    end

    describe '#walk_stop' do

      it 'only makes one request' do
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do
        an_atis_request_for('Walkstop',
          'Startlat' => '33.45455', 'Startlong' => '-112.07064', 'Endlat' => '33.45586', 'Endlong' => '-112.07255'
          ).should have_been_made
      end

      it 'parses out fields correctly' do
        @walk.legs.should eql [{description: 'Do some walking'}, {description: 'Walk some more'}]
        @walk.walk_distance.should eql '1.2'
        @walk.walk_units.should eql 'miles'
        @walk.walk_time.should eql '22'
      end

    end

    describe '#to_hash' do

      it 'returns only the correct keys' do
        hash = {legs: [{description: 'Do some walking'}, {description: 'Walk some more'}], walk_distance: '1.2', walk_units: 'miles', walk_time: '22'}
        HashDiff.diff(@walk.to_hash, hash).should eql []
      end

    end

  end

end

