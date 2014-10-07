require 'spec_helper'

describe Ratis::Request do
  context 'new Requests get config from Ratis.configure block' do
    it 'gets config from initializing' do
      pending
      Ratis::Request.client.wsdl.endpoint.should eql('http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi')
      Ratis::Request.client.wsdl.namespace.should eql('PX_WEB')
    end
  end

  context 'configured incorrectly' do
    context 'without Ratis.configure being called' do
      it 'raises an exception when initialized before configuring' do
        expect(Ratis.config).to receive(:valid?).at_least(:once) { false }
        expect do
          Ratis::Request.get 'SomeAction'
        end.to raise_error Ratis::Errors::ConfigError, 'It appears that Ratis.configure has not been called or properly setup'
      end
    end
  end
end

describe Ratis::Request do
  describe '#get' do
    describe 'with no parameters' do
      it 'only makes one request with the correct SOAP action' do

        Ratis::Request.client.should_receive(:request) do |action, options|
          action.should eq('Mymethod')
          options[:soap_action].should eq("PX_WEB#Mymethod")
          options[:xmlns].should eq("PX_WEB")
        end.once

        Ratis::Request.get 'Mymethod'
      end

      it 'returns the response' do
        response = Ratis::Request.get 'Getcategories'
        response.should be_a(Savon::SOAP::Response)
        response.should be_success
      end
    end

    describe 'with parameters' do
      it 'passes the parameters' do
        response = Ratis::Request.get 'Point2point',
                                      {"Routesonly"      => true,
                                       "Originlat"       => 33.446931,
                                       "Originlong"      => -112.097903,
                                       "Destinationlat"  => 33.447098,
                                       "Destinationlong" => -112.077213,
                                       "Date"             => Date.today.strftime("%m/%d/%Y"),
                                       "Starttime"       => '1700',
                                       "Endtime"         => '1800'}

        response.should be_a(Savon::SOAP::Response)
        response.should be_success
      end
    end

    describe 'unsuccessful requests' do
      describe 'connection refused' do
        it 'wraps the underlying error in a NetworkError ' do
          Ratis::Request.client.should_receive(:request){ raise(Errno::ECONNREFUSED ) }

          expect do
            Ratis::Request.get 'Mymethod'
          end.to raise_error Ratis::Errors::NetworkError
        end
      end

      describe 'with errorneous parameters' do
        it 'parses out fault code and strings' do
          begin
            Ratis::Request.get 'Closeststop', {'Locationlat' => '1', 'Locationlong' => '1'}

          rescue Ratis::Errors::SoapError => e
            e.fault_code.should eql 15016
            e.fault_string.should eql 'SOAP - invalid Locationtext'
            e.verbose_fault_string.should eql 'Either the origin or destination could not be recognized by the server'
          end
        end

        it 'raises an SoapError' do
          expect do
            Ratis::Request.get 'Mymethod'
          end.to raise_error(Ratis::Errors::SoapError)
        end
      end

    end
  end
end

describe Ratis::Request do
  describe '#all_conditions_used?' do
    it 'raises an exception if there are members in the hash' do
      expect do
        Ratis.all_conditions_used? :a => 1

      end.to raise_error ArgumentError, 'Conditions not used by this class: [:a]'
    end

    it 'does not raise an exception for an empty hash' do
      expect do
        Ratis.all_conditions_used? Hash.new

      end.not_to raise_error
    end
  end
end
