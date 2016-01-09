require 'spec_helper'

describe Eiger::Scope do
  let(:level0) { Eiger::Scope.new }
  let(:level1) { Eiger::Scope.new('level1', level0) }
  let(:level2) { Eiger::Scope.new('level2', level1) }

  context 'nesting paths' do
    it 'returns correct path for level 1' do
      expect(level1.absolute_path).to eq '/level1'
    end

    it 'returns correct path for level 2' do
      expect(level2.absolute_path).to eq '/level1/level2'
    end
  end

  context 'initial scope' do
    it 'returns empty path' do
      expect(level0.absolute_path).to eq ''
    end
  end
end
