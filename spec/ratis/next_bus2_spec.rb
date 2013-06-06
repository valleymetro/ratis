require 'spec_helper'

# NOTE: this should be called NextBus2 or something as that's the API call it really makes.
# need to find all places where this is used and update them before being able to push a new
# gem version for this backwards breaking change
describe Ratis::NextBus2 do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-252/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  describe '#where' do
    before do
      # appid
      # a short string that can be used to separate requests from different applications or different modules with
      # Optional (highly recommended)
      @today      = Time.now.strftime("%m/%d/%Y")
      @conditions = {:stop_id      => 10050,
                     :app_id       => 'ratis-specs'}
    end

    it 'stops' do
      pending
      # raises exception when no runs available:
      # Ratis::Errors::SoapError:
      # SOAP - no runs available
      response = Ratis::NextBus2.where(@conditions.dup)
      debugger
      x = 1
    end

    it 'runs' do
      pending
    end
  end

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

      # @next_bus = Ratis::NextBus2.where :stop_id => 10496, :app_id => 'web'
    end

    describe '#where' do

      it 'only makes one request' do
        pending
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do
        pending
        an_atis_request_for('Nextbus2', 'Stopid' => '10496', 'Appid' => 'web').should have_been_made
      end

      it 'returns a non nil NextBus' do
        pending
        @next_bus.should_not be_nil
      end

    end

    describe '#to_hash' do

      it 'returns a subset of NextBus params' do
        pending
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
        pending
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

end

