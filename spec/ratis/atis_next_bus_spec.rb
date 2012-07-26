require 'spec_helper'

describe AtisNextBus do

  describe 'single next bus at 10496' do

    let(:next_bus_time_scheduled) { 10.minutes.from_now.strftime '%H:%M %p' }
    let(:next_bus_time_estimated) { 12.minutes.from_now.strftime '%H:%M %p' }

    before do
      stub_atis_request.to_return( atis_response 'Nextbus2', '1.3', '0', <<-BODY )
      <Input>
        <Stopid>10496</Stopid>
        <Atisstopid>0</Atisstopid>
        <Route></Route>
        <Runs>999</Runs>
        <Xmode></Xmode>
        <Date>#{ Time.now.strftime '%m/%d/%y' }</Date>
        <Time>#{ Time.now.strftime '%H:%M %p' }</Time>
      </Input>
      <Stops>
        <Stop>
          <Stopid>10496</Stopid>
          <Atisstopid>366</Atisstopid>
          <Stopstatustype>N</Stopstatustype>
          <Description>FILLMORE ST & CENTRAL AVE</Description>
          <Lat>33.454483</Lat>
          <Long>-112.073307</Long>
          <Stopposition>G</Stopposition>
          <Heading>EB</Heading>
          <Side>Far</Side>
        </Stop>
      </Stops>
      <Runs>
        <Run>
          <Route>7</Route>
          <Sign>7 7th Street to Union Hills Via Cent Station</Sign>
          <Operator>AP</Operator>
          <Direction>N</Direction>
          <Status>N</Status>
          <Servicetype>W</Servicetype>
          <Routetype>B</Routetype>
          <Triptime>#{ next_bus_time_scheduled }</Triptime>
          <Tripid>85-20</Tripid>
          <Adherence>0</Adherence>
          <Estimatedtime>#{ next_bus_time_estimated }</Estimatedtime>
          <Polltime></Polltime>
          <Lat></Lat>
          <Long></Long>
          <Block>22</Block>
          <Exception></Exception>
          <Atisstopid>366</Atisstopid>
          <Stopid>10496</Stopid>
        </Run>
      </Runs>
      BODY

      @next_bus = AtisNextBus.where :stop_id => 10496, :app_id => 'web'
    end

    describe '#where' do

      it 'only makes one request' do
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do
        an_atis_request_for('Nextbus2', 'Stopid' => '10496', 'Appid' => 'web').should have_been_made
      end

      it 'returns a non nil AtisNextBus' do
        @next_bus.should_not be_nil
      end

    end

    describe '#to_hash' do

      it 'returns a subset of NextBus params' do

        hash = {
          :stopname => 'FILLMORE ST & CENTRAL AVE',
          :signs => ['7 7th Street to Union Hills Via Cent Station'],
          :runs => [
            { :time => next_bus_time_estimated, :adherence => '0', :route => '7', :sign => '7 7th Street to Union Hills Via Cent Station' }
          ]
        }

        HashDiff.diff(@next_bus.to_hash, hash).should eql []

      end

    end

    describe '#to_hash_for_xml' do

      it 'returns a subset of NextBus params' do

        hash = {
          :stopname => 'FILLMORE ST & CENTRAL AVE',
          :runs => [
            { :time => next_bus_time_estimated, :adherence => '0', :route => '7', :sign => '7 7th Street to Union Hills Via Cent Station', :scheduled_time => next_bus_time_scheduled }
          ]
        }

        HashDiff.diff(@next_bus.to_hash_for_xml, hash).should eql []

      end

    end

  end

  describe 'multiple next buses at 10496' do

    pending 'implement'

  end

end

