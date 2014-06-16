require 'spec_helper'

describe Ratis::LocationTypeAhead do
  describe '#where', vcr: {} do
    let(:conditions) { { :search => '1315 w straford dr' } }

    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::LocationTypeAhead.where(conditions.dup)
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Locationtypeahead')
        options["Search"].should eq('1315 w straford dr')
      end.and_return(double('response', :success? => false))

      Ratis::LocationTypeAhead.where(conditions.dup)
    end

    it 'should return a collection of Ratis::LocationTypeAheadItem(s)' do
      locations = Ratis::LocationTypeAhead.where(conditions.dup)
      locations.each do |obj|
        expect(obj).to be_a(Ratis::LocationTypeAheadItem)
      end
    end

    it 'parses out fields correctly' do
      locations = Ratis::LocationTypeAhead.where(conditions.dup)
      location = locations.first

      expect(location.name).to eql '1315 W STRAFORD DR'
      expect(location.area).to eql 'Chandler'
      expect(location.areacode).to eql 'CH'
      expect(location.postcode).to be_nil # Applies only to landmarks
      expect(location.type).to eql 'N'
    end
  end
end
