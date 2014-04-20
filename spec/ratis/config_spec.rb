require 'spec_helper'

describe Ratis::Config do

  context 'with an endpoint and namespace set' do

    describe '#valid?' do

      it 'is valid' do
        Ratis.config.valid?.should be_true
      end

    end

  end

  context 'without an endpoint or namespace set' do

    before do
      # Override Ratis.configure made in spec_helper.rb
      # Ratis.config = Ratis::Config.new
    end

    describe '#valid?' do

      it 'is not valid' do
        pending('Need way in specs to set new config after one is set.')
        Ratis.config.valid?.should be_false
      end

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

