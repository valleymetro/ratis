require 'spec_helper'

describe Ratis::Area do
  describe '#all', vcr: {} do
    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Area.all
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Getareas')
      end.and_return(double('response', :success? => false))

      Ratis::Area.all
    end

    it 'should return all areas' do
      pending
      areas = Ratis::Area.all
      areas.should have(29).items
    end

    it "should parse the area fields" do
      pending
      areas = Ratis::Area.all
      area  = areas.last

      expect(area.area).to eq('YG')
      expect(area.description).to eq('Youngtown')
    end
  end
end
