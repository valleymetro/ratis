require 'spec_helper'

describe Ratis::Routes do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  let(:empty_body){ {:allroutes2_response => {:routes => []}} }

  describe '#all', vcr: {} do
    it 'returns all routes' do
      response = Ratis::Routes.all
      expect(response).to have(104).items
      expect(response.all?{|rte| rte.is_a?(Ratis::Route) }).to be_true
    end

    it 'only makes one request' do
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Routes.all
    end

    it 'requests the correct SOAP action' do
      Ratis::Request.should_receive(:get) do |action, options|
                       action.should eq('Allroutes2')
                     end.and_return(double('response', :success? => false, :body => empty_body)) # false only to stop further running

      Ratis::Routes.all
    end

    it 'should set directions and short_name to variables' do
      response = Ratis::Routes.all
      route    = response.first

      expect(response).to be_a(Array)
      expect(route).to be_a(Ratis::Route)
      expect(route.short_name).to eq('1')
      expect(route.directions).to have(2).directions
      expect(route.directions).to include('E')
      expect(route.directions).to include('W')
    end

  end

  describe '#timetable' do
    it "description" do
      pending
    end
  end

end
