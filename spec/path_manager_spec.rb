# coding: UTF-8
require 'spec_helper'

describe Eiger::PathManager do
  describe '#params' do
    describe 'defined by names' do
      let(:only) { Eiger::PathManager.new('/:leading') }
      let(:one) { Eiger::PathManager.new('/:leading/test') }
      let(:double) { Eiger::PathManager.new('/:leading/test/:leading') }
      let(:middle) { Eiger::PathManager.new('/foo/:middle/bar') }
      let(:at_the_end) { Eiger::PathManager.new('/foo/:bar') }
      let(:many) { Eiger::PathManager.new('/:foo/test/:bar') }

      it 'returns params' do
        expect(only.params('/foo')['leading']).to eq 'foo'
        expect(one.params('/foo/test')['leading']).to eq 'foo'
        expect(double.params('/foo/test/bar')['leading']).to eq 'bar'
        expect(middle.params('/bar/test/foo')['middle']).to eq 'test'
        expect(at_the_end.params('/foo/foo')['bar']).to eq 'foo'
        expect(many.params('/bar/test/foo')['bar']).to eq 'foo'
        expect(many.params('/bar/test/foo/test/')['foo']).to eq 'bar'
      end
    end

    context 'defined by *' do
      let(:one) { Eiger::PathManager.new('/*/foo') }
      let(:many) { Eiger::PathManager.new('/*/foo/*/*') }

      it 'finds one param' do
        expect(one.params('/bar/foo')['splat']).to include 'bar'
      end

      it 'finds many params' do
        expect(many.params('/bar/foo/one/two')['splat']).to include 'bar'
        expect(many.params('/bar/foo/one/two')['splat']).to include 'one'
        expect(many.params('/bar/foo/one/two')['splat']).to include 'two'
        expect(many.params('/bar/foo/one/t/h')['splat']).to include 't/h'
      end
    end

    context 'mixed params' do
      let(:subject) { Eiger::PathManager.new('/:foo/*/foo') }

      it 'parses name param' do
        expect(subject.params('/foo/bar/foo')['foo']).to eq 'foo'
      end

      it 'parses splat param' do
        expect(subject.params('/foo/bar/foo')['splat']).to include 'bar'
      end
    end
  end
end
