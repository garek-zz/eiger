require 'spec_helper'

describe Eiger::Controller, type: :controller do
  class TestController < Eiger::Controller; end

  describe '#get_child_or_self' do
    let(:subject) { Eiger::Controller }

    it 'returns Controller subclass' do
      expect(subject.get_child_or_self(:test_controller)).to be(TestController)
    end

    it 'returns Controller class' do
      expect(subject.get_child_or_self).to be(Eiger::Controller)
    end

    it 'returns nil for not defined subclass' do
      expect { subject.get_child_or_self(:test) }.to raise_error(NameError)
    end
  end

  describe '#add_method' do
    let(:subject) { Eiger::Controller }
    let(:block) { -> { 'index' } }
    let(:overwrite_block) { -> { 'overwrite' } }

    context 'when action not exists' do
      it 'adds index method' do
        expect(subject.method_defined?(:index)).to be false
        subject.add_method(:index, &block)
        expect(subject.method_defined?(:index)).to be true
      end

      it 'assigns block body to new method' do
        subject.add_method(:index, &block)
        expect(subject.new({}).index).to eq 'index'
      end
    end

    context 'when action exists' do
      before do
        subject.add_method(:index, &block)
      end

      it 'overwrites method' do
        subject.add_method(:index, &overwrite_block)
        expect(subject.new({}).index).to eq 'overwrite'
      end
    end
  end
end
