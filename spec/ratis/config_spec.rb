require 'spec_helper'

describe Ratis::Config do
  it 'is valid' do
    expect(Ratis.config).to be_valid
  end

  context 'nil endpoint' do
    it 'is not valid' do
      expect(Ratis.config).to receive(:endpoint).at_least(:once).and_return(nil)
      expect(Ratis.config).to_not be_valid
    end
  end

  context 'empty endpoint' do
    it 'is not valid' do
      expect(Ratis.config).to receive(:endpoint).at_least(:once).and_return('')
      expect(Ratis.config).to_not be_valid
    end
  end

  context 'nil namespace' do
    it 'is not valid' do
      expect(Ratis.config).to receive(:namespace).at_least(:once).and_return(nil)
      expect(Ratis.config).to_not be_valid
    end
  end

  context 'empty namespace' do
    it 'is not valid' do
      expect(Ratis.config).to receive(:namespace).at_least(:once).and_return('')
      expect(Ratis.config).to_not be_valid
    end
  end
end
