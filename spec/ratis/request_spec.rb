require 'spec_helper'

describe Ratis::Request do

  context 'configured correctly' do

    around(:each) do |example|
      rollback_ratis_config(&example)
    end

    it 'delegates to Savon client' do
      Ratis.configure do |config|
        config.appid = 'myappid'
        config.endpoint = 'myendpoint'
        config.namespace = 'mynamespace'
        config.timeout = 666
      end

      Ratis::Request.client.should_receive(:request) do |action, options|
        options[:soap_action].should eq("mynamespace#SomeAction")
        Ratis::Request.client.http.read_timeout.should eql 666

      end.once

      Ratis::Request.get 'SomeAction'

      # change the configuration
      Ratis.configure do |config|
        config.appid = 'anotherappid'
        config.endpoint = 'anotherendpoint'
        config.namespace = 'anothernamespace'
        config.timeout = 321
      end

      Ratis::Request.client.should_receive(:request) do |action, options|
        options[:soap_action].should eq("anothernamespace#SomeAction")
        Ratis::Request.client.http.read_timeout.should eql 321

      end.once

      Ratis::Request.get 'SomeAction'
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
          end.to raise_error do |error|
            error.should be_a(Ratis::Errors::NetworkError)
            error.nested.should be_a(Errno::ECONNREFUSED)
            error.message.should eql('Refused request to ATIS SOAP server')
          end
        end
      end

      describe 'with errorneous parameters' do
        it 'parses out fault code and strings' do
          expect do
            Ratis::Request.get 'Closeststop', {'Locationlat' => '1', 'Locationlong' => '1'}
          end.to raise_error do |error|
            error.should be_a(Ratis::Errors::SoapError)
            error.fault_code.should eql 15016
            error.fault_string.should eql 'SOAP - invalid Locationtext'
            error.verbose_fault_string.should eql 'Either the origin or destination could not be recognized by the server'
          end
        end

        it 'raises an SoapError' do
          expect do
            Ratis::Request.get 'Mymethod'
          end.to raise_error(Ratis::Errors::SoapError)
        end
      end

      describe 'a timeout occurs' do
        it 'wraps the underlying error in a NetworkError ' do
          Ratis::Request.client.should_receive(:request){ raise(Timeout::Error) }

          expect do
            Ratis::Request.get 'Mymethod'
          end.to raise_error do |error|
            error.should be_a(Ratis::Errors::NetworkError)
            error.nested.should be_a(Timeout::Error)
            error.message.should eql("Request to ATIS SOAP server timed out after #{ Ratis.config.timeout }s")
          end
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
