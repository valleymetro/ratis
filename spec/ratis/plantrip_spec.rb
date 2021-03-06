require 'spec_helper'

describe Ratis::Plantrip do
  before do
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
      expect(@plantrip.itineraries.first.dist_auto).to eq(0.87)
    end

    it "should set all the Plantrip values to instance vars" do
      plantrip = Ratis::Plantrip.where(@conditions.dup)
      expect(plantrip.walkable).to eq(nil)
      expect(plantrip.walkadjust).to eq(nil)

      input = Ratis::Plantrip::Input.new({
        :originlat             => "33.452082",
        :originlong            => "-112.074374",
        :originlandmarkid      => "0",
        :origintext            => "Origin",
        :destinationlat        => "33.446347",
        :destinationlong       => "-112.068689",
        :destinationlandmarkid => "0",
        :destinationtext       => "Destination",
        :date                  => "06/16/2014",
        :time                  => "06:00 AM",
        :minimize              => "T",
        :accessible            => "N",
        :arrdep                => "D",
        :maxtransfers          => "-1",
        :maxanswers            => "3",
        :lessttime             => "N",
        :maxinitialwait        => "-1",
        :maxtriptime           => "-1",
        :walkspeed             => " 2.00 ",
        :walkdist              => "0.50",
        :walkorigin            => "0.50",
        :walkdestination       => "0.50",
        :walkincrease          => "N",
        :allows2s              => "N",
        :xmode                 => "BCFKLRSTX"
      })

      HashDiff.diff(plantrip.input, input).should eql []
    end

    it "should set the Plantrip legs to instance vars" do
      conditions = @conditions.dup
      conditions[:destination_lat] = '33.454055'
      conditions[:destination_long] = '-111.953385'
      plantrip = Ratis::Plantrip.where(conditions)

      itin_with_one_leg = plantrip.itineraries.first
      itin_with_two_legs = plantrip.itineraries.last

      expect(itin_with_one_leg).to have(1).legs
      expect(itin_with_two_legs).to have(2).legs

      itin_with_one_leg.legs.each do |leg|
        expect(leg).to be_a(Hashie::Mash)
      end

      itin_with_two_legs.legs.each do |leg|
        expect(leg).to be_a(Hashie::Mash)
      end
    end

    it 'passes a Tid through' do
      tid = 'here is my Tid'
      conditions_with_tid = @conditions.merge({ tid: tid })
      @itineraries = Ratis::Plantrip.where conditions_with_tid
      expect(@itineraries.tid).to eql(tid)
    end

  end

end

