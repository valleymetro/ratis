require 'spec_helper'

describe Hash do

  describe 'which is one level deep' do

    describe '#to_array' do

      it 'returns [] if key is not present in Hash' do
        {}.to_array(:a).should eql []
      end

      it 'returns [] if key is nil ' do
        { :a => nil }.to_array(:a).should eql []
      end

      it 'returns [value] if value is not an Array' do
        { :a => 1 }.to_array(:a).should eql [1]
      end

      it 'returns Array if value is an Array' do
        { :a => [1,2,3] }.to_array(:a).should eql [1,2,3]
      end

    end

  end

  describe 'which is two levels deep' do

    describe '#to_array' do

      it 'returns [] if key is not present in Hash' do
        { :a => {} }.to_array(:a, :b).should eql []
      end

      it 'returns [] if key is nil ' do
        { :a => { :b => nil } }.to_array(:a, :b).should eql []
      end

      it 'returns [value] if value is not an Array' do
        { :a => { :b => 1 } }.to_array(:a, :b).should eql [1]
      end

      it 'returns Array if value is an Array' do
        { :a => { :b => [1,2,3] } }.to_array(:a, :b).should eql [1,2,3]
      end

    end

  end

end

