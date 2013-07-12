require 'spec_helper'

describe Ratis::Route do
  before do
    Ratis.reset
    Ratis.configure do |config|
      config.endpoint   = 'http://soap.valleymetro.org/cgi-bin-soap-web-262/soap.cgi'
      config.namespace  = 'PX_WEB'
    end
  end


  describe '#initialize' do
    it "description" do
      pending
    end
  end

  describe '#timetable' do
    it "description" do
      pending
    end
  end
end