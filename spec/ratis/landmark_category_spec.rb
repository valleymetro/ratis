require 'spec_helper'

describe Ratis::LandmarkCategory do

  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  describe '.all', vcr: {} do
    it 'only makes one request' do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::LandmarkCategory.all
    end

    it 'requests the correct SOAP action with correct args' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Getcategories')

      end.and_return(double('response', :success? => false))

      Ratis::LandmarkCategory.all
    end

    it 'should return a collection of Ratis::LandmarkCategory(s)' do
      categories = Ratis::LandmarkCategory.all
      categories.each do |obj|
        expect(obj).to be_a(Ratis::LandmarkCategory)
      end
    end

    it 'should return all landmark categories' do
      categories = Ratis::LandmarkCategory.all
      categories.should have(76).items
    end
  end

  describe '.web_categories', vcr: {} do
    it "does something" do
      web_categories = Ratis::LandmarkCategory.web_categories
      expect(web_categories).to have(14).items

      [["AIRPORT", "WEBAIR"], ["COLLEGES", "WEBCOL"], ["COMMUNITY RESOURCES", "WEBCMR"], ["FAMILY ATTRACTIONS", "WEBFAM"], ["GOVT LOCAL STATE FEDERAL", "WEBGOV"], ["HOSPITALS AND CLINICS", "WEBHOS"], ["LIBRARIES", "WEBLIB"], ["LIGHT RAIL STATIONS", "WEBSTN"], ["MUSEUMS", "WEBMUS"], ["PARK AND RIDE", "WEBPR"], ["PERFORMING ARTS", "WEBPER"], ["SHOPPING MALLS", "WEBSHP"], ["SPORTS VENUES", "WEBSPT"], ["TRANSIT CENTERS", "WEBTC"]].each do |pair|
        expect(web_categories).to include(pair)
      end
    end
  end

end

