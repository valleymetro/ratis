require 'spec_helper'

describe Ratis::Landmark do

  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end

  describe "#where" do
    before do
      @conditions = {:type => 'all',
                     :zipcode => '85224'}
    end

    it 'only makes one request' do
      pending 'Need method turned on in ATIS'

      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Landmark.where(@conditions.dup)
    end
  end

  it 'requests the correct SOAP action' do
    pending
    an_atis_request_for('Getlandmarks', 'Type' => 'ALL').should have_been_made
  end

  it 'should return all landmarks' do
    pending
    @landmarks.should have(2).items

    @landmarks[0].type.should eql 'AIRPT'
    @landmarks[0].verbose.should eql 'FALCON FIELD AIRPORT'
    @landmarks[0].location.should eql '4800 E. FALCON DR.'
    @landmarks[0].locality.should eql 'N'

    @landmarks[1].type.should eql 'AIRPT'
    @landmarks[1].verbose.should eql 'SKY HARBOR AIRPORT TERMINAL 4 WB'
    @landmarks[1].location.should eql '3700 E SKY HARBOR BLVD'
    @landmarks[1].locality.should eql 'N'
  end

end
