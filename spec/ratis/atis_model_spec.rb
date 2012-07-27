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
        an_atis_request_for('MyMethod').should have_been_made
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
        an_atis_request_for('MyMethod', { 'ParamOne' => 'apple', 'ParamTwo' => '3' }).should have_been_made
      end

    end

  end

  describe '#all_criteria_used?' do

    it 'raises an exception if there are members in the hash' do
      expect do
        dummy_class.all_criteria_used? :a => 1
      end.to raise_error ArgumentError, 'Criteria not used by this class: [:a]'
    end

    it 'does not raise an exception for an empty hash' do
      expect do
        dummy_class.all_criteria_used? Hash.new
      end.not_to raise_error
    end

  end

end

