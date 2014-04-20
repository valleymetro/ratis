require 'spec_helper'

describe Ratis::Plantrip do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end

    @datetime    = Chronic.parse('next monday at 6am')
  end

  let(:empty_body){ {:plantrip_response => {:input => {}} }}

  describe '#where', vcr: {} do
    before do
      @conditions = {
        :datetime         => @datetime,
        :minimize         => 'T',
        :origin_lat       => '33.452082',
        :origin_long      => '-112.074374',
        :destination_lat  => '33.446347',
        :destination_long => '-112.068689'}
    end

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Plantrip.where(@conditions.dup)
    end

    it 'requests the correct SOAP action' do
      Ratis::Request.should_receive(:get) do |action, options|
                       action.should eq('Plantrip')
                       options["Appid"].should eq('ratis-gem')
                       options["Date"].should eq(@datetime.strftime("%m/%d/%Y"))
                       options["Time"].should eq(@datetime.strftime("%H%M"))
                       options["Minimize"].should eq('T')
                       options['Originlat'].should eq(33.452082)
                       options['Originlong'].should eq(-112.074374)
                       options['Destinationlat'].should eq(33.446347)
                       options['Destinationlong'].should eq(-112.068689)

                     end.and_return(double('response', :success? => false, :body => empty_body, :to_array => [])) # false only to stop further running

      Ratis::Plantrip.where(@conditions.dup)
    end

    it 'returns a Plantrip object' do
      @itineraries = Ratis::Plantrip.where(@conditions.dup)
      expect(@itineraries).to be_a(Ratis::Plantrip)
    end

    it 'creates Ratis::Itineraries for each trip itinerary' do
      @plantrip = Ratis::Plantrip.where(@conditions.dup)
      @plantrip.itineraries.should have(3).items
      expect(@plantrip.itineraries.first).to be_a(Ratis::Itinerary)
    end

    it "should set all the Plantrip values to instance vars" do
      plantrip = Ratis::Plantrip.where(@conditions.dup)
      expect(plantrip.walkable).to eq(nil)
      expect(plantrip.walkadjust).to eq(nil)

      input = {
        :accessible            => "N",
        :arrdep                => "D",
        :date                  => "01/13/2014",
        :destinationlandmarkid => "0",
        :destinationlat        => "33.446347",
        :destinationlong       => "-112.068689",
        :destinationtext       => "Destination",
        :minimize              => "T",
        :originlandmarkid      => "0",
        :originlat             => "33.452082",
        :originlong            => "-112.074374",
        :origintext            => "Origin",
        :time                  => "06:00 AM",
        :walkdestination       => "0.50",
        :walkdist              => "0.50",
        :walkorigin            => "0.50",
        :walkspeed             => " 2.00 "
      }

      HashDiff.diff(plantrip.input, input).should eql []
    end

  end

end

