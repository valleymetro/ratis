require 'spec_helper'

describe Ratis::Landmark do
  describe "#where" do
    let(:conditions) { { :type => '*', :zipcode => '85224' } }

    it 'only makes one request', vcr: {} do
      # false just to stop further processing of response
      Ratis::Request.should_receive(:get).once.and_call_original
      Ratis::Landmark.where(conditions.dup)
    end

    it 'requests the correct SOAP action' do
      Ratis::Request.should_receive(:get) do |action, options|
        action.should eq('Getlandmarks')
        options["Type"].should eq(conditions[:type])
        options["Zipcode"].should eq(conditions[:zipcode])
      end.and_return(double('response', :success? => false))

      Ratis::Landmark.where(conditions.dup)
    end

    it "should return a collection of Ratis::Landmark(s)", vcr: {} do
      stops = Ratis::Landmark.where(conditions.dup)
      stops.each do |obj|
        expect(obj).to be_a(Ratis::Landmark)
      end
    end

    it 'returns multiple landmarks', vcr: {} do
      stops = Ratis::Landmark.where(conditions.dup)
      stops.should have(1034).items
    end

    it 'parses out the landmark fields correctly', vcr: {} do
      landmarks = Ratis::Landmark.where(conditions.dup)
      landmark  = landmarks.first

      expect(landmark.type).to eq('LRT')
      expect(landmark.verbose).to eq('12JF')
      expect(landmark.location).to eq('S 12TH ST & E JEFFERSON ST')
      expect(landmark.locality).to eq('N')
    end

    it "should raise error for missing arg type" do
      conds = conditions.dup
      conds.delete(:type)

      expect do
        Ratis::Landmark.where(conds)
      end.to raise_error(ArgumentError, 'You must provide a type')
    end
  end

end
