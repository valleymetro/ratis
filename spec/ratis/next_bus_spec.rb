require 'spec_helper'

describe Ratis::NextBus do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end

    @time    = Chronic.parse('next monday at 6am')
  end

  let(:empty_body){ {:nextbus_response => {:atstop => {:service => []}}} }

  describe "Developer can find a late bus to a stop" do
    it "will give developer happiness :-)" do
      pending
      @conditions = {:app_id       => 'ratis-specs', # a short string that can be used to separate requests from different applications or different modules with
                     :type         => 'N',
                     :datetime     => Chronic.parse('now') }

      require 'pp'
      10000.upto(10100).each do |id|
        puts id
        response = Ratis::NextBus.where(@conditions.dup.merge(:stop_id => id)) rescue next

        response.services.each do |service|
          service.trips.each do |trip|
            if trip.realtime.valid != 'N'
              puts trip.realtime
            end
          end
        end
      end
    end
  end

  describe '#success?' do
    it "do something" do
      pending
    end
  end

  describe '#where', {:vcr => {:cassette_name => "Nextbus_running_LATE", :re_record_interval => 6.months}} do #
    # TODO: Light Rails Stops can return 2 Atstop tags... how do we best handle this case
    describe 'Light Rails stops' do
      it "description" do
        pending
      end
    end

    describe 'time formatting' do
      it 'should make requests with 24 hour time format' do
        @stop_id    = 10050
        @time       = Chronic.parse('tomorrow at 3pm')
        @conditions = {:stop_id      => @stop_id,
                       :app_id       => 'ratis-specs', # a short string that can be used to separate requests from different applications or different modules with
                       :type         => 'N',
                       :datetime     => @time }

        Ratis::Request.should_receive(:get) do |action, options|
                         action.should eq('Nextbus')
                         options["Time"].should eq(@time.strftime("%H%M"))

                       end.and_return(double('response', :success? => false, :body => empty_body)) # false only to stop further running

        Ratis::NextBus.where(@conditions.dup)
      end
    end

    describe 'single service return' do
      before do
        @stop_id = 10050
        @conditions = {:stop_id      => @stop_id,
                       :app_id       => 'ratis-specs', # a short string that can be used to separate requests from different applications or different modules with
                       :type         => 'N',
                       :datetime     => @time }

      end

      it 'returns the next bus times' do
        # raises exception when no runs available:
        # Ratis::Errors::SoapError:
        # SOAP - no runs available
        response = Ratis::NextBus.where(@conditions.dup)
        expect(response.services).to have(1).items
      end

      it 'only makes one request' do
        # false just to stop further processing of response
        Ratis::Request.should_receive(:get).once.and_call_original
        Ratis::NextBus.where(@conditions.dup)
      end

      it 'requests the correct SOAP action' do
        Ratis::Request.should_receive(:get) do |action, options|
                         action.should eq('Nextbus')
                         options["Stopid"].should eq(@stop_id)
                         options["Appid"].should eq('ratis-specs')
                         options["Date"].should eq(@time.strftime("%m/%d/%Y"))
                         options["Time"].should eq(@time.strftime("%H%M"))
                         options["Type"].should eq('N')

                       end.and_return(double('response', :success? => false, :body => empty_body)) # false only to stop further running

        Ratis::NextBus.where(@conditions.dup)
      end

      it "should set all the service values to instance vars" do
        response = Ratis::NextBus.where(@conditions.dup)
        service = response.services.first
        expect(response).to be_a(Ratis::NextBus)
        expect(response.services).to be_a(Array)

        expect(service.status).to eq('N')
        expect(service.sign).to eq('0 CENTRAL North to Dunlap/3rd St.')
        expect(service.routetype).to eq('B')
        expect(service.times).to eq("05:49 AM, 06:09 AM, 06:29 AM, 06:49 AM")
        expect(service.direction).to eq('N')
        expect(service.servicetype).to eq('W')
        expect(service.route).to eq('ZERO')
        expect(service.operator).to eq('AP')
      end

      it "should raise error if datetime condition is not a DateTime or Time" do
        lambda {
          Ratis::NextBus.where(@conditions.dup.merge(:datetime => '01/01/2013'))
        }.should raise_error(ArgumentError, 'If datetime supplied it should be a Time or DateTime instance, otherwise it defaults to Time.now')

        lambda {
          Ratis::NextBus.where(@conditions.dup.merge(:datetime => Time.now))
        }.should_not raise_error(ArgumentError)

        lambda {
          Ratis::NextBus.where(@conditions.dup.merge(:datetime => DateTime.today))
        }.should_not raise_error(ArgumentError)
      end

      it "should raise error if stop id is not provided" do
        lambda {
          Ratis::NextBus.where(@conditions.dup.merge(:stop_id => nil))
        }.should raise_error(ArgumentError, 'You must provide a stop ID')
      end

      it "should return an empty array if the api request isn't successful" do
        Ratis::Request.should_receive(:get) do |action, options|
                         action.should eq('Nextbus')
                         options["Stopid"].should eq(@stop_id)
                         options["Appid"].should eq('ratis-specs')
                         options["Date"].should eq(@time.strftime("%m/%d/%Y"))
                         options["Time"].should eq(@time.strftime("%H%M"))
                         options["Type"].should eq('N')

                       end.and_return(double('response', :success? => false, :body => empty_body)) # false only to stop further running

        expect(Ratis::NextBus.where(@conditions.dup).services).to be_empty
      end
    end

    describe 'multiple services returned' do
      before do
        @stop_id = 15894
        @time       = Chronic.parse('next monday at 3pm')
        @conditions = {:stop_id      => @stop_id,
                       :app_id       => 'ratis-specs', # a short string that can be used to separate requests from different applications or different modules with
                       :type         => 'N',
                       :datetime     => @time }
      end

      it 'returns the next 4 bus times' do
        # raises exception when no runs available:
        # Ratis::Errors::SoapError:
        # SOAP - no runs available
        response = Ratis::NextBus.where(@conditions.dup)
        expect(response.services.size).to be_within(2).of(3)
      end

      it 'only makes one request' do
        # false just to stop further processing of response
        Ratis::Request.should_receive(:get).once.and_call_original
        Ratis::NextBus.where(@conditions.dup)
      end

      it 'requests the correct SOAP action' do
        Ratis::Request.should_receive(:get) do |action, options|
                         action.should eq('Nextbus')
                         options["Stopid"].should eq(@stop_id)
                         options["Appid"].should eq('ratis-specs')
                         options["Date"].should eq(@time.strftime("%m/%d/%Y"))
                         options["Time"].should eq(@time.strftime("%H%M"))
                         options["Type"].should eq('N')

                       end.and_return(double('response', :success? => false, :body => empty_body)) # false only to stop further running

        Ratis::NextBus.where(@conditions.dup)
      end

      it "should map all the services to service openstruct objects" do
        response = Ratis::NextBus.where(@conditions.dup)
        expect(response).to be_a(Ratis::NextBus)
        expect(response.services).to be_a(Array)

        service = response.services.first
        expect(service).to be_a(OpenStruct)

        expect(service.status).to eq('N')
        expect(service.sign).to eq('0 CENTRAL North to Dunlap/3rd St.')
        expect(service.routetype).to eq('B')
        expect(service.times).to eq("05:49 AM, 06:09 AM, 06:29 AM, 06:49 AM")
        expect(service.direction).to eq('N')
        expect(service.servicetype).to eq('W')
        expect(service.route).to eq('ZERO')
        expect(service.operator).to eq('AP')

        service = response.services.last
        expect(service).to be_a(OpenStruct)

        expect(service.status).to eq('N')
        expect(service.sign).to eq('0 CENTRAL North to Dunlap/3rd St.')
        expect(service.routetype).to eq('B')
        expect(service.times).to eq("05:49 AM, 06:09 AM, 06:29 AM, 06:49 AM")
        expect(service.direction).to eq('N')
        expect(service.servicetype).to eq('W')
        expect(service.route).to eq('ZERO')
        expect(service.operator).to eq('AP')
      end

      it "should raise error if datetime condition is not a DateTime or Time" do
        lambda {
          Ratis::NextBus.where(@conditions.dup.merge(:datetime => '01/01/2013'))
        }.should raise_error(ArgumentError, 'If datetime supplied it should be a Time or DateTime instance, otherwise it defaults to Time.now')

        lambda {
          Ratis::NextBus.where(@conditions.dup.merge(:datetime => Time.now))
        }.should_not raise_error(ArgumentError)

        lambda {
          Ratis::NextBus.where(@conditions.dup.merge(:datetime => DateTime.today))
        }.should_not raise_error(ArgumentError)
      end

      it "should raise error if stop id is not provided" do
        lambda {
          Ratis::NextBus.where(@conditions.dup.merge(:stop_id => nil))
        }.should raise_error(ArgumentError, 'You must provide a stop ID')
      end

      it "should return an empty array if the api request isn't successful" do
        Ratis::Request.should_receive('get') do |action, options|
                        action.should eq('Nextbus')
                        options["Time"].should eq(@time.strftime("%H%M") )
                        options["Type"].should eq("N")
                        options["Stopid"].should eq(@stop_id)
                        options["Date"].should eq(@time.strftime("%m/%d/%Y") )
                        options["Appid"].should eq("ratis-specs")

                      end.and_return(double('response', :success? => false, :body => empty_body))

        expect(Ratis::NextBus.where(@conditions.dup).services).to be_empty
      end
    end
  end



end

# EXAMPLE RESPONSE
# {:envelope => {
#   :"@xmlns:xsd"               =>"http://www.w3.org/1999/XMLSchema",
#   :"@xmlns:xsi"               =>"http://www.w3.org/1999/XMLSchema-instance",
#   :"@xmlns:soap_env"          =>"http://schemas.xmlsoap.org/soap/envelope/",
#   :"@xmlns:soap_enc"          =>"http://schemas.xmlsoap.org/soap/encoding/",
#   :"@soap_env:encoding_style" =>"http://schemas.xmlsoap.org/soap/encoding/",
#   :body => {
#     :nextbus_response => {
#       :atstop => {
#         :side => "Far",
#         :stopid => "10050",
#         :heading => "NB",
#         :lat => "33.363692",
#         :area => "Phoenix",
#         :service => {
#           :status => "N",
#           :sign => "0 CENTRAL North to Dunlap/3rd St.",
#           :routetype => "B",
#           :times => "10:29 AM, 10:49 AM, 11:09 AM, 11:29 AM",
#           :direction => "N",
#           :tripinfo => [
#              {:tripid => "8374-8",
#               :exception => "N",
#               :skedtripid => nil,
#               :estimatedtime => "10:29 AM",
#               :triptime => "10:29 AM",
#               :adherence => nil,
#               :realtime => {
#                 :valid => nil,
#                 :reliable => nil,
#                 :estimatedtime => "10:29 AM",
#                 :stopped => nil,
#                 :lat => nil,
#                 :estimatedminutes => nil,
#                 :vehicleid => nil,
#                 :polltime => nil,
#                 :long => nil,
#                 :adherence => nil,
#                 :trend => nil,
#                 :speed => nil},
#               :block => "3"
#              },
#              {:tripid => "8374-8",
#               :exception => "N",
#               :skedtripid => nil,
#               :estimatedtime => "10:49 AM",
#               :triptime => "10:49 AM",
#               :adherence => nil,
#               :realtime => {
#                 :valid => nil,
#                 :reliable => nil,
#                 :estimatedtime => "10:49 AM",
#                 :stopped => nil,
#                 :lat => nil,
#                 :estimatedminutes => nil,
#                 :vehicleid => nil,
#                 :polltime => nil,
#                 :long => nil,
#                 :adherence => nil,
#                 :trend => nil,
#                 :speed => nil
#                },
#                :block => "5"
#              },
#              {:tripid => "8374-9",
#               :exception => "N",
#               :skedtripid => nil,
#               :estimatedtime => "11:09 AM",
#               :triptime => "11:09 AM",
#               :adherence => nil,
#               :realtime => {
#                 :valid => nil,
#                 :reliable => nil,
#                 :estimatedtime => "11:09 AM",
#                 :stopped => nil,
#                 :lat => nil,
#                 :estimatedminutes => nil,
#                 :vehicleid => nil,
#                 :polltime => nil,
#                 :long => nil,
#                 :adherence => nil,
#                 :trend => nil,
#                 :speed => nil
#               },
#               :block => "8"},
#              {:tripid => "8374-9",
#               :exception => "N",
#               :skedtripid => nil,
#               :estimatedtime => "11:29 AM",
#               :triptime => "11:29 AM",
#               :adherence => nil,
#               :realtime => {
#                 :valid => nil,
#                 :reliable => nil,
#                 :estimatedtime => "11:29 AM",
#                 :stopped => nil,
#                 :lat => nil,
#                 :estimatedminutes => nil,
#                 :vehicleid => nil,
#                 :polltime => nil,
#                 :long => nil,
#                 :adherence => nil,
#                 :trend => nil,
#                 :speed => nil
#               },
#               :block => "11"}
#           ],
#         :servicetype => "W",
#         :route => "0",
#         :operator => "AP"
#       },
#       :description => "CENTRAL AVE & DOBBINS RD",
#       :atisstopid => "3317",
#       :stopposition => "O",
#       :long => "-112.073191",
#       :stopstatustype => "N",
#       :walkdist => "0.00"
#     },
#     :version => "1.26",
#     :responsecode => "0",
#     :input => {
#       :time => "10:40 AM",
#       :stopid => "10050",
#       :date => "06/05/2013",
#       :locationlat => nil,
#       :landmarkid => nil,
#       :locationlong => nil,
#       :atisstopid => "0",
#       :locationtext => "Location",
#       :route => nil
#     },
#     :host => "s-rpta-soap",
#     :"@xmlns:namesp1" => "PX_WEB",
#     :copyright => "XML schema Copyright (c) 2003-2012 Trapeze Software, Inc., all rights reserved.",
#     :soapversion => "2.5.2 - 06/07/12"}}}}

