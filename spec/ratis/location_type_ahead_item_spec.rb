require 'spec_helper'

describe Ratis::LocationTypeAheadItem do
  let(:item){ Ratis::LocationTypeAheadItem.new(name: '1315 W STRAFORD DR',
                                               area: 'Chandler',
                                               areacode: 'CH',
                                               postcode: '85224',
                                               type: 'N') }

  describe '#initialize' do
    it "should correct assign instance variables" do
      expect(item.name).to eq('1315 W STRAFORD DR')
      expect(item.area).to eq('Chandler')
      expect(item.areacode).to eq('CH')
      expect(item.postcode).to eq('85224')
      expect(item.type).to eq('N')
    end

  end

end