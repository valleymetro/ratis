require 'spec_helper'

describe AtisModel do

  let(:dummy_class) do
    Class.new do
      extend AtisModel

      implement_soap_action 'Mymethod', 1.23
    end
  end

  context 'configured correctly' do

    it 'gets config from spec_helper' do
      dummy_class.client.wsdl.endpoint.should eql 'http://example.com/soap.cgi'
      dummy_class.client.wsdl.namespace.should eql 'TEST_NS'
    end

  end

  context 'configured incorrectly' do

    context 'without Ratis.configure being called' do

      before do
        # Override Ratis.configure made in spec_helper.rb
        Ratis.config = Ratis::Config.new
      end

      it 'raises an exception when initializing a class which extends AtisModel' do
        expect do
          dummy_class
        end.to raise_error RuntimeError, 'It appears that Ratis.configure has not been called'
      end

      after do
        # Reset Ratis.configure made in spec_helper.rb
        Ratis.configure do |config|
          config.endpoint = 'http://example.com/soap.cgi'
          config.namespace = 'TEST_NS'
        end
      end

    end

  end

  describe '#who_implements_soap_action' do
    before do
      @another_dummy_class = Class.new do
        extend AtisModel
        implement_soap_action 'Testaction', 1.23
      end
    end

    it 'finds a class which extends AtisModel with a SOAP action' do
      classes = AtisModel.who_implements_soap_action('Testaction')
      classes.should have(1).item
      classes.first.should eql @another_dummy_class
    end

  end

  describe '#atis_request' do

    describe 'successful' do

      before do
        stub_atis_request.to_return atis_response('Mymethod', '1.23', '0', '<body>test response body here</body>')
      end

      describe 'with no parameters' do

        before do
          @response = dummy_class.atis_request 'Mymethod'
        end

        it 'only makes one request' do
          an_atis_request.should have_been_made.times 1
        end

        it 'requests the correct SOAP action' do
          an_atis_request_for('Mymethod').should have_been_made
        end

        it 'returns the response' do
          @response.class.should eql Savon::SOAP::Response
          @response.to_hash[:mymethod_response][:body].should eql 'test response body here'
        end

      end

      describe 'with parameters' do

        before do
          @response = dummy_class.atis_request 'Mymethod', { 'ParamOne' => 'apple', 'ParamTwo' => 3 }
        end

        it 'passes the parameters' do
          an_atis_request_for('Mymethod', { 'ParamOne' => 'apple', 'ParamTwo' => '3' }).should have_been_made
        end

      end

    end

    describe 'unsuccessful' do

      describe 'connection refused' do

        before do
          stub_atis_request.to_raise Errno::ECONNREFUSED.new('Connection refused - connect(2)')
        end

        it 're-raises an ECONNREFUSED' do
          expect do
            dummy_class.atis_request 'Mymethod'
          end.to raise_error Errno::ECONNREFUSED, 'Connection refused - Refused request to ATIS SOAP server'
        end

      end

      describe 'with errorneous parameters' do

        before do
          stub_atis_request.to_return atis_error_response(10222, '#10222--Unknown stop')
        end

        it 'raises an AtisError' do
          expect do
            dummy_class.atis_request 'Mymethod'
          end.to raise_error AtisError
        end

        it 'parses out fault code and strings' do
          begin
            dummy_class.atis_request 'Mymethod'
          rescue AtisError => e
            e.fault_code.should eql 10222
            e.fault_string.should eql '#10222--Unknown stop'
            e.verbose_fault_string.should eql 'Invalid STOP ID number. Please enter a valid five digit stop ID number'
          end
        end

      end

      describe 'unimplemented method version' do

        before do
          stub_atis_request.to_return atis_response('Mymethod', '1.24', '0', '<body>test response body here</body>')
        end

        it 'raises an AtisError' do
          expect do
            dummy_class.atis_request 'Mymethod'
          end.to raise_error AtisError
        end

        it 'error gives version used by server' do
          begin
            dummy_class.atis_request 'Mymethod'
          rescue AtisError => e
            e.fault_code.should be_nil
            e.fault_string.should eql 'Unimplemented SOAP method Mymethod 1.24'
            e.verbose_fault_string.should eql 'The server could not handle your request at this time.  Please try again later'
          end

        end

      end


    end

  end

  describe '#all_conditions_used?' do

    it 'raises an exception if there are members in the hash' do
      expect do
        dummy_class.all_conditions_used? :a => 1
      end.to raise_error ArgumentError, 'Conditions not used by this class: [:a]'
    end

    it 'does not raise an exception for an empty hash' do
      expect do
        dummy_class.all_conditions_used? Hash.new
      end.not_to raise_error
    end

  end

end

