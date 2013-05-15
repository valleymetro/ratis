require 'spec_helper'

describe Ratis::Area do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-252/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  describe '#all' do
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
      areas = Ratis::Area.all
      areas.should have(29).items
    end

    it "should parse the area fields" do
      areas = Ratis::Area.all
      area  = areas.last

      expect(area.area).to eq('YG')
      expect(area.description).to eq('Youngtown')
    end
  end

end