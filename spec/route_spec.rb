require 'spec_helper'
require 'minitest/autorun'

describe Eiger::Route do
  let(:foo) { '/foo' }
  let(:bar) { '/bar' }
  let(:block) { -> { 'test' } }
  let(:action) { :index }
  let(:request) { MiniTest::Mock.new }
  let(:options) do
    { controller: TestApp, action: action, scope_path: '' }
  end
  let(:subject) { Eiger::Route.new(foo, options, &block) }

  before do
    request.expect(:path, '/')
    request.expect(:params, {})
    allow(subject.path_manager).to receive(:match).with(foo) { true }
    allow(subject.path_manager).to receive(:match).with(bar) { false }
  end

  describe '#call_method' do
    it 'calls index method in TestApp class' do
      expect(subject.call_method(request)).to eq 'index'
    end
  end

  describe '#match' do
    it 'returns true' do
      expect(subject.match(foo)).to be true
    end

    it 'returns false' do
      expect(subject.match(bar)).to be false
    end
  end

  describe '#add_method' do
    it 'defined method for TestApp controller' do
      expect(TestApp.method_defined?(action)).to be true
    end
  end
end
