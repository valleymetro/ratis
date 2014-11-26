require 'spec_helper'

describe Ratis::Location do
  let(:conditions) { { :location => '1315 W. Straford Dr.', :media => 'W' } }

  describe '#where', vcr: {} do

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Location.where(conditions.dup)
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Locate')
        options["Location"].should eq('1315 W. Straford Dr.')
        options["Maxanswers"].should eq(20)
        options["Media"].should eq('W')

      end.and_return(double('response', :success? => false))

      Ratis::Location.where(conditions.dup)
    end

    it 'should return a collection of Ratis::Location(s)' do
      locations = Ratis::Location.where(conditions.dup)
      locations.each do |obj|
        expect(obj).to be_a(Ratis::Location)
      end
    end

    it 'parses out fields correctly' do
      locations = Ratis::Location.where(conditions.dup)
      first_location = locations.first

      expect(first_location.name).to eql 'W STRAFORD DR'
      expect(first_location.area).to eql 'Chandler'
      expect(first_location.responsecode).to eql 'ok'
      expect(first_location.areacode).to eql 'CH'
      expect(first_location.latitude).to eql '33.353202'
      expect(first_location.longitude).to eql '-111.864902'
      expect(first_location.landmark_id).to eql '0'
      expect(first_location.address).to eql '1315'
      expect(first_location.startaddr).to be_nil
      expect(first_location.endaddr).to be_nil
      expect(first_location.address_string).to eql '1315 W STRAFORD DR (in Chandler)'
    end

  end

  describe '#to_a' do
    it 'returns lat, lon, name and landmark_id' do
      pending
      @first_location.to_a.should eql ['33.5811205', '-112.2989325', 'W PENNSYLVANIA AVE', '0']
    end
  end

  describe '#to_hash', vcr: {} do
    it 'returns all params' do
      params = [:name, :area, :areacode, :region, :zipname, :latitude, :longitude, :address, :address_string, :landmark_id, :responsecode, :startaddr, :endaddr, :startlatitude, :startlongitude, :endlatitude, :endlongitude]
      locations = Ratis::Location.where(conditions.dup)

      expect(locations.first.to_hash.keys.to_set).to eql params.to_set
    end

  end

  describe '#address_string' do
    it "does something" do
      pending
    end
  end

  describe '#full_address' do
    it "does something" do
      pending
    end
  end
end
