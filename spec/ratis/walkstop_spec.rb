require 'spec_helper'

describe Ratis::Walkstop do
  let(:empty_body) { { :walkstop_response => {} } }
  let(:conditions) {
    {
      :start_lat  => '33.511990',
      :start_long => '-111.880344',
      :end_lat    => '33.512091',
      :end_long   => '-111.880349'
    }
  }

  describe '#where', vcr: {} do
    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Walkstop.where(conditions.dup)
    end

    it 'requests the correct SOAP action' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Walkstop')
        options["Startlat"].should eq(conditions[:start_lat])
        options["Startlong"].should eq(conditions[:start_long])
        options["Endlat"].should eq(conditions[:end_lat])
        options["Endlong"].should eq(conditions[:end_long])
      end.and_return(double('response', :success? => false))

      Ratis::Walkstop.where(conditions.dup)
    end

    it 'should set all the walkstop values to instance vars' do
      walkstop = Ratis::Walkstop.where(conditions.dup)

      expect(walkstop).to be_a(Ratis::Walkstop)
      expect(walkstop.legs).to be_a(Array)

      expect(walkstop.legs).to eq(['Walk a short distance N on Scottsdale Community College.'])
      expect(walkstop.walk_distance).to eql('0.05')
      expect(walkstop.walk_units).to eql('miles')
      expect(walkstop.walk_time).to eql('2')
      expect(walkstop.start_text).to eq('Origin')
      expect(walkstop.end_text).to eq('Destination')
    end

    it "should return an empty array if the api request isn't successful" do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Walkstop')
        options["Startlat"].should eq(conditions[:start_lat])
        options["Startlong"].should eq(conditions[:start_long])
        options["Endlat"].should eq(conditions[:end_lat])
        options["Endlong"].should eq(conditions[:end_long])

      end.and_return(double('response', :success? => false, :body => empty_body)) # false only to stop further running

      expect(Ratis::Walkstop.where(conditions.dup).legs).to be_empty
    end
  end

  describe '#to_hash' do
    it 'returns only the correct keys' do
      walkstop = Ratis::Walkstop.where(conditions.dup)
      hash     = {:legs=>["Walk a short distance N on Scottsdale Community College."], :walk_distance=>"0.05", :walk_units=>"miles", :walk_time=>"2"}
      expect( HashDiff.diff(walkstop.to_hash, hash) ).to eql([])
    end
  end
end

