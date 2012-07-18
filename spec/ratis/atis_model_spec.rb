require 'spec_helper'

describe AtisModel do

  let(:dummy_class) do
    Class.new do
      extend AtisModel
    end
  end

  describe '#atis_request' do

    before do
      stub_atis_request.to_return atis_response('MyMethod', '1', '0', '<body>test response body here</body>')
    end

    describe 'with no parameters' do

      before do
        @response = dummy_class.atis_request 'MyMethod'
      end

      it 'only makes one request' do
        an_atis_request.should have_been_made.times 1
      end

      it 'requests the correct SOAP action' do
        an_atis_request.with{ |request| request.headers['Soapaction'] == '"PX_WEB#MyMethod"' }.should have_been_made
      end

      it 'returns the response' do
        @response.class.should eql Savon::SOAP::Response
        @response.to_hash[:my_method_response][:body].should eql 'test response body here'
      end

    end

    describe 'with parameters' do

      before do
        @response = dummy_class.atis_request 'MyMethod', { 'ParamOne' => 'apple', 'ParamTwo' => 3 }
      end

      it 'passes the parameters' do
        params_as_soap = '<MyMethod xmlns="PX_WEB"><ParamOne>apple</ParamOne><ParamTwo>3</ParamTwo></MyMethod>'
        an_atis_request.with{ |request| request.body.include? params_as_soap }.should have_been_made
      end

    end

  end

end

