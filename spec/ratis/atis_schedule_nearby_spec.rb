require 'spec_helper'

describe AtisScheduleNearby do

  describe 'single stop nearby' do

    describe 'with single service' do

      describe 'with a single trip' do

        before do
          stub_atis_request.to_return( atis_response 'Schedulenearby', '1.20', '0', <<-BODY )
          <Input>
            <Locationlat>33.4556</Locationlat>
            <Locationlong>-112.071807</Locationlong>
            <Locationtext></Locationtext>
            <Landmarkid>0</Landmarkid>
            <Stopid></Stopid>
            <Route></Route>
            <Date>07/23/12</Date>
            <Time>1:23 PM</Time>
          </Input>
          <Atstop>
            <Walkdist>0.41</Walkdist>
            <Walkdir>NW</Walkdir>
            <Description>ROOSEVELT&#x2F;CENTRAL AVE LIGHT RAIL STATION</Description>
            <Atisstopid>10879</Atisstopid>
            <Stopid>10011</Stopid>
            <Lat>33.459821</Lat>
            <Long>-112.073847</Long>
            <Stopposition>O</Stopposition>
            <Heading>NB</Heading>
            <Side>Far</Side>
            <Stopstatustype>N</Stopstatustype>
            <Service>
              <Route>LTRL</Route>
              <Sign>Metro light rail To 44th St&#x2F;Washington</Sign>
              <Operator>LRT</Operator>
              <Direction>E</Direction>
              <Status>N</Status>
              <Servicetype>U</Servicetype>
              <Routetype>L</Routetype>
              <Times>12:10 AM</Times>
              <Tripinfo>
                <Triptime>12:10 AM</Triptime>
                <Tripid>1262-0</Tripid>
                <Block>17630</Block>
                <Exception>N</Exception>
              </Tripinfo>
            </Service>
          </Atstop>
          BODY

          @schedule_nearby = AtisScheduleNearby.where(
            latitude: '33.4556', longitude: '-112.071807',
            date: '07/23/12', time: '1323', window: '60', walk_distance: '0.50',
            landmark_id: '0', stop_id: nil, app_id: 'na')

        end

        describe '#where' do

          it 'only makes one request' do
            an_atis_request.should have_been_made.times 1
          end

          it 'requests the correct SOAP action' do
            an_atis_request_for('Schedulenearby', 
              'Locationlat' => '33.4556', 'Locationlong' => '-112.071807',
              'Date' => '07/23/12', 'Time' => '1323', 'Window' => '60', 'Walkdist' => '0.50',
              'Landmarkid' => '0', 'Stopid' => '', 'Appid' => 'na'
            ).should have_been_made
          end

          it 'returns a non nil AtisScheduleNearby' do
            @schedule_nearby.should_not be_nil
          end

          it 'returns a single stop' do
            @schedule_nearby.atstops.should have(1).item
          end

          it 'returns a single service at the stop' do
            @schedule_nearby.atstops.first[:services].should have(1).item
          end

        end

        describe '#to_hash' do

          it 'returns a subset of Schedule params' do

            hash =
              { :atstops=>
                [
                  { :walkdir=>"NW", :walkdist=>"0.41", :description=>"ROOSEVELT/CENTRAL AVE LIGHT RAIL STATION",
                    :lat=>"33.459821", :stopid=>"10011", :long=>"-112.073847",
                    :services=>[
                      { :routetype=>"L", :times=>"12:10 AM", :operator=>"LRT",
                        :route=>"LTRL", :sign=>"Metro light rail To 44th St/Washington",
                        :trips=> [ { :triptime=>"12:10 AM"} ]
                      }
                    ]
                  }
                ]
              }

            HashDiff.diff(@schedule_nearby.to_hash, hash).should eql []

          end

        end

      end

    end

  end

  describe 'two stops nearby' do

    describe 'each with two services' do

      describe 'each with two trips' do

        before do
          stub_atis_request.to_return( atis_response 'Schedulenearby', '1.20', '0', <<-BODY )
          <Input>
            <Locationlat>+33.451929</Locationlat>
            <Locationlong>-112.07457</Locationlong>
            <Locationtext></Locationtext>
            <Atisstopid></Atisstopid>
            <Stopid></Stopid>
            <Landmarkid>0</Landmarkid>
            <Date>07/25/12</Date>
            <Time>01:00 PM</Time>
            <Route></Route>
          </Input>
          <Atstop>
            <Walkdist>0.05</Walkdist>
            <Walkdir>W</Walkdir>
            <Description>1ST AVE &amp; VAN BUREN ST</Description>
            <Atisstopid>3795</Atisstopid>
            <Stopid>10161</Stopid>
            <Lat>33.451748</Lat>
            <Long>-112.075169</Long>
            <Stopposition>S</Stopposition>
            <Heading>SB</Heading>
            <Side>Near</Side>
            <Stopstatustype>N</Stopstatustype>
            <Service>
              <Route>0</Route>
              <Sign>0 CENTRAL South to Dobbins</Sign>
              <Operator>AP</Operator>
              <Direction>S</Direction>
              <Status>N</Status>
              <Servicetype>W</Servicetype>
              <Routetype>B</Routetype>
              <Times>12:40 PM, 01:00 PM</Times>
              <Tripinfo>
                <Triptime>12:40 PM</Triptime>
                <Tripid>3352-10</Tripid>
                <Block>4</Block>
                <Exception>N</Exception>
              </Tripinfo>
              <Tripinfo>
                <Triptime>01:00 PM</Triptime>
                <Tripid>3352-11</Tripid>
                <Block>6</Block>
                <Exception>N</Exception>
              </Tripinfo>
            </Service>
            <Service>
              <Route>0</Route>
              <Sign>0 Central South To Baseline Rd</Sign>
              <Operator>AP</Operator>
              <Direction>S</Direction>
              <Status>N</Status>
              <Servicetype>W</Servicetype>
              <Routetype>B</Routetype>
              <Times>01:30 PM, 01:45 PM</Times>
              <Tripinfo>
                <Triptime>01:30 PM</Triptime>
                <Tripid>3353-5</Tripid>
                <Block>13</Block>
                <Exception>N</Exception>
              </Tripinfo>
              <Tripinfo>
                <Triptime>01:45 PM</Triptime>
                <Tripid>3354-5</Tripid>
                <Block>13</Block>
                <Exception>N</Exception>
              </Tripinfo>
            </Service>
          </Atstop>
          <Atstop>
            <Walkdist>0.09</Walkdist>
            <Walkdir>SW</Walkdir>
            <Description>VAN BUREN ST &amp; 1ST AVE</Description>
            <Atisstopid>1825</Atisstopid>
            <Stopid>10342</Stopid>
            <Lat>33.451367</Lat>
            <Long>-112.075485</Long>
            <Stopposition>E</Stopposition>
            <Heading>EB</Heading>
            <Side>Near</Side>
            <Stopstatustype>N</Stopstatustype>
            <Service>
              <Route>3</Route>
              <Sign>3 VAN BUREN East to 48th St.</Sign>
              <Operator>FT</Operator>
              <Direction>E</Direction>
              <Status>D</Status>
              <Servicetype>W</Servicetype>
              <Routetype>B</Routetype>
              <Times>12:59 PM, 01:29 PM</Times>
              <Tripinfo>
                <Triptime>12:59 PM</Triptime>
                <Tripid>3380-7</Tripid>
                <Block>2010</Block>
                <Exception>N</Exception>
              </Tripinfo>
              <Tripinfo>
                <Triptime>01:29 PM</Triptime>
                <Tripid>3380-8</Tripid>
                <Block>2007</Block>
                <Exception>N</Exception>
              </Tripinfo>
            </Service>
            <Service>
              <Route>3</Route>
              <Sign>3 VAN BUREN East to Phoenix Zoo</Sign>
              <Operator>FT</Operator>
              <Direction>E</Direction>
              <Status>D</Status>
              <Servicetype>W</Servicetype>
              <Routetype>B</Routetype>
              <Times>12:44 PM, 01:14 PM</Times>
              <Tripinfo>
                <Triptime>12:44 PM</Triptime>
                <Tripid>3377-3</Tripid>
                <Block>2012</Block>
                <Exception>N</Exception>
              </Tripinfo>
              <Tripinfo>
                <Triptime>01:14 PM</Triptime>
                <Tripid>3376-3</Tripid>
                <Block>2004</Block>
                <Exception>N</Exception>
              </Tripinfo>
            </Service>
          </Atstop>
          BODY

          @schedule_nearby = AtisScheduleNearby.where(
            latitude: '33.4556', longitude: '-112.071807',
            date: '07/25/12', time: '1300', window: '60', walk_distance: '1.00',
            landmark_id: '0', stop_id: nil, app_id: 'na')

        end

        describe '#where' do

          it 'only makes one request' do
            an_atis_request.should have_been_made.times 1
          end

          it 'requests the correct SOAP action' do
            an_atis_request_for('Schedulenearby',
              'Locationlat' => '33.4556', 'Locationlong' => '-112.071807',
              'Date' => '07/25/12', 'Time' => '1300', 'Window' => '60', 'Walkdist' => '1.00',
              'Landmarkid' => '0', 'Stopid' => '', 'Appid' => 'na'
            ).should have_been_made
          end

          it 'returns a non nil AtisScheduleNearby' do
            @schedule_nearby.should_not be_nil
          end

          it 'returns both stops' do
            @schedule_nearby.atstops.should have(2).items
          end

          it 'returns both services at both stops' do
            @schedule_nearby.atstops.each do |atstop|
              atstop[:services].should have(2).items
            end
          end

          it 'returns both trips for both services at both stops' do
            @schedule_nearby.atstops.each do |atstop|
              atstop[:services].each do |service|
                service[:tripinfos].should have(2).items
              end
            end
          end

        end

      describe '#to_hash' do

        it 'returns a subset of Schedule params' do

          hash =
            { :atstops=>
              [
                { :walkdir=>"W", :walkdist=>"0.05", :description=>"1ST AVE & VAN BUREN ST",
                  :lat=>"33.451748", :stopid=>"10161", :long=>"-112.075169",
                  :services=>[
                    { :routetype=>"B", :times=>"12:40 PM, 01:00 PM", :operator=>"AP",
                      :route=>"0", :sign=>"0 CENTRAL South to Dobbins",
                      :trips=> [ { :triptime=>"12:40 PM" }, { :triptime=>"01:00 PM" } ]
                    },
                    { :routetype=>"B", :times=>"01:30 PM, 01:45 PM", :operator=>"AP",
                      :route=>"0", :sign=>"0 Central South To Baseline Rd",
                      :trips=> [ { :triptime=>"01:30 PM" }, { :triptime=>"01:45 PM" } ]
                    }
                  ]
                },
                { :walkdir=>"SW", :walkdist=>"0.09", :description=>"VAN BUREN ST & 1ST AVE",
                  :lat=>"33.451367", :stopid=>"10342", :long=>"-112.075485",
                  :services=>[
                    { :routetype=>"B", :times=>"12:59 PM, 01:29 PM", :operator=>"FT",
                      :route=>"3", :sign=>"3 VAN BUREN East to 48th St.",
                      :trips=> [ { :triptime=>"12:59 PM" }, { :triptime=>"01:29 PM" } ]
                    },
                    { :routetype=>"B", :times=>"12:44 PM, 01:14 PM", :operator=>"FT",
                      :route=>"3", :sign=>"3 VAN BUREN East to Phoenix Zoo",
                      :trips=> [ { :triptime=>"12:44 PM" }, { :triptime=>"01:14 PM" } ]
                    }
                  ]
                }
              ]
            }

            HashDiff.diff(@schedule_nearby.to_hash, hash).should eql []

          end

        end

      end

    end

  end

end

