require 'spec_helper'

describe Ratis::ScheduleNearby do
  describe '#where', vcr: {} do
    before do
      @today      = Time.now.strftime("%m/%d/%Y")
      @conditions = {:latitude      => '33.4556',
                     :longitude     => '-112.071807',
                     :date          => @today,
                     :time          => '1323',
                     :window        => '60',
                     :walk_distance => '0.18',
                     :landmark_id   => '0',
                     :stop_id       => nil }
    end

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::ScheduleNearby.where(@conditions.dup)
    end

    it 'should return no data error when date is in the past' do
      old_date_conditions = @conditions.merge(:date => '01/28/2012')
      expect do
        Ratis::ScheduleNearby.where(old_date_conditions)
      end.to raise_error(Ratis::Errors::SoapError, "#20005--No service at origin at the date/time specified")
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Schedulenearby')
        options["Locationlat"].should eq(@conditions[:latitude])
        options["Locationlong"].should eq(@conditions[:longitude])
        options["Date"].should eq(@conditions[:date])
        options["Time"].should eq(@conditions[:time])
        options["Window"].should eq(@conditions[:window])
        options["Walkdist"].should eq(@conditions[:walk_distance])
        options["Landmarkid"].should eq(@conditions[:landmark_id])
        options["Stopid"].should eq('')

      end.and_return(double('response', :success? => false))

      Ratis::ScheduleNearby.where(@conditions.dup)
    end

    it 'returns a non nil ScheduleNearby' do
      Ratis::ScheduleNearby.where(@conditions.dup).should_not be_nil
    end

    it 'returns all the stops' do
      Ratis::ScheduleNearby.where(@conditions.dup).atstops.should have(3).items
    end

    it 'returns a single service at the stop' do
      Ratis::ScheduleNearby.where(@conditions.dup).atstops.first[:services].should have(1).item
    end

    describe 'with single service' do
      describe 'with a single trip' do
        describe '#to_hash' do

          it 'returns a subset of Schedule params' do
            pending('find a call that returns less results')
            hash =
              { :atstops=>
                [
                  { :walkdir=>"NW", :walkdist=>"0.41", :description=>"ROOSEVELT/CENTRAL AVE LIGHT RAIL STATION",
                    :lat=>"33.459821", :stopid=>"10011", :heading => "NB", :long=>"-112.073847",
                    :services=>[
                      { :routetype=>"L", :times=>"12:10 AM", :operator=>"LRT",
                        :route=>"LTRL", :sign=>"Metro light rail To 44th St/Washington",
                        :trips=> [ { :triptime=>"12:10 AM"} ],
                      }
                    ]
                  }
                ]
              }

            HashDiff.diff(Ratis::ScheduleNearby.where(@conditions.dup), hash).should eql []
          end
        end
      end
    end

  end



  describe 'two stops nearby' do

    describe 'each with two services' do

      describe '#to_hash' do

        it 'returns a subset of Schedule params' do
          pending
          hash =
            { :atstops=>
              [
                { :walkdir=>"W", :walkdist=>"0.05", :description=>"1ST AVE & VAN BUREN ST",
                  :lat=>"33.451748", :stopid=>"10161", :heading=>"SB", :long=>"-112.075169",
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
                  :lat=>"33.451367", :stopid=>"10342", :heading=>"EB", :long=>"-112.075485",
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

