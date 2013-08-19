require 'spec_helper'

describe Ratis::NextBus2 do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  let(:empty_body){ {:nextbus_response => {:atstop => {:service => []}}} }

  describe '#where' do
    before do
      # appid
      # a short string that can be used to separate requests from different applications or different modules with
      # Optional (highly recommended)
      @stop_id = 10040
      @conditions = {:stop_id      => @stop_id,
                     :app_id       => 'ratis-specs'}
    end

    describe "Developer can find a late bus to a stop" do
      it "will give developer happiness :-)" do

        require 'pp'
        10001.upto(10039).each do |id|
          puts id
          response = Ratis::NextBus2.where(@conditions.dup.merge(:stop_id => id))
          # expect(response.stops).to_not be_empty
          # expect(response.runs).to_not be_empty

          response.runs.each do |run|
            if run[:realtime][:valid] != 'N'
              pp run[:realtime]
            end
          end
      end
    end

    describe 'single next bus' do
      it "only makes one request" do
        # false just to stop further processing of response
        Ratis::Request.should_receive(:get).once.and_call_original
        Ratis::NextBus2.where(@conditions.dup)
      end

      it 'requests the correct SOAP action with args' do
        Ratis::Request.should_receive(:get) do |action, options|
                       action.should eq('Nextbus2')
                       options["Stopid"].should eq(@stop_id)

                     end.and_return(double('response', :success? => false, :body => empty_body)) # false only to stop further running

        Ratis::NextBus2.where(@conditions.dup)
      end

      it "description", {:vcr => {:cassette_name => "Nextbus2_running_LATE", :re_record_interval => 6.months}} do

        response = Ratis::NextBus2.where(@conditions.dup)
        late_run = response.runs.first
        expect(late_run[:realtime][:valid]).to eq("Y")
        expect(late_run[:realtime][:estimatedtime]).to_not eq(late_run[:triptime])
        expect(late_run[:realtime][:reliable]).to eq("Y")
        expect(late_run[:realtime][:estimatedtime]).to eq("02:52 PM")
        expect(late_run[:realtime][:estimatedminutes]).to eq("16")

        # :realtime=>{:valid=>"Y", :estimatedtime=>"02:52 PM", :reliable=>"Y", :stopped=>"N", :estimatedminutes=>"16", :lat=>"33.451187", :polltime=>"02:35 PM", :long=>"-111.982079", :adherence=>"0", :trend=>"D", :speed=>"0.00", :vehicleid=>"6050"},
      end

      it 'requests the correct SOAP action' do
        response = Ratis::NextBus2.where(@conditions.dup.merge(:stop_id => id))
          expect(response.stops).to_not be_empty
          expect(response.runs).to_not be_empty
        end
      end

      it "should raise error when no stop id provided" do
        lambda {
          Ratis::NextBus2.where(@conditions.dup.merge(:stop_id => nil))
        }.should raise_error(ArgumentError, 'You must provide a stop ID')
      end

      describe 'stops' do
        # TODO: should return Stops not hashes
        it 'should set the stop values to instance vars' do
          response = Ratis::NextBus2.where(@conditions.dup)
          stop     = response.stops.first

          expect(response).to be_a(Ratis::NextBus2)
          expect(response.stops).to be_a(Array)

          expect(stop[:area]).to eq("Phoenix")
          expect(stop[:atisstopid]).to eq("3317")
          expect(stop[:stopposition]).to eq("O")
          expect(stop[:description]).to eq("CENTRAL AVE & DOBBINS RD")
          expect(stop[:stopstatustype]).to eq("N")
          expect(stop[:lat]).to eq("33.363692")
          expect(stop[:long]).to eq("-112.073191")
          expect(stop[:side]).to eq("Far")
          expect(stop[:stopid]).to eq("10050")
          expect(stop[:heading]).to eq("NB")
        end

        it "should return an empty array if the api request isn't successful" do
          Ratis::Request.should_receive(:get) do |action, options|
                           action.should eq('Nextbus2')
                           options["Stopid"].should eq(@stop_id)

                         end.and_return(double('response', :success? => false, :body => empty_body)) # false only to stop further running

          response = Ratis::NextBus2.where(@conditions.dup)
          expect(response).to be_a(Array)
          expect(response).to be_empty
        end
      end

      describe 'runs' do
        # TODO: should return Runs not hashes
        it "should set the run values to instance vars" do
          response = Ratis::NextBus2.where(@conditions.dup)
          run     = response.runs.first

          expect(response).to be_a(Ratis::NextBus2)
          expect(response.runs).to be_a(Array)

          expect(run[:operator]).to eq "AP"
          expect(run[:status]).to eq "N"
          expect(run[:sign]).to eq "0 CENTRAL North to Dunlap/3rd St."
          expect(run[:triptime]).to_not be_nil #eq "12:29 PM"
          expect(run[:triptime]).to_not be_empty
          # expect(run.realtime=>{:valid=>nil, :estimatedminutes=>nil, :polltime=>nil, :lat=>nil, :trend=>nil, :vehicleid=>nil, :speed=>nil, :adherence=>nil, :long=>nil, :reliable=>nil, :estimatedtime=>"12:09 PM", :stopped=>nil}
          expect(run[:exception]).to be_nil
          expect(run[:tripid]).to eq "10709-11"
          expect(run[:routetype]).to eq "B"
          expect(run[:skedtripid]).to be_nil
          expect(run[:stopid]).to eq "10050"
          expect(run[:servicetype]).to eq "W"
          expect(run[:adherence]).to be_nil
          expect(run[:atisstopid]).to eq "3317"
          # expect(run[:block]).to eq "5"
          expect(run[:route]).to eq "ZERO"
          expect(run[:estimatedtime]).to_not be_nil
          expect(run[:estimatedtime]).to_not be_empty
          expect(run[:direction]).to eq "N"
        end
      end

    end
  end

  describe '#first_stop_description' do
    it "should return the correct description" do
      pending
    end
  end

  describe '#to_hash' do
    it "description" do
      pending
    end
  end

  describe '#to_hash_for_xml' do
    it "description" do
      pending
    end
  end
end

