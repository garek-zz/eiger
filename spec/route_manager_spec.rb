require 'minitest/autorun'
require 'spec_helper'

describe Eiger::RouteManager do
  before do
    class Page < Eiger::Controller
      def index; end
    end
  end

  describe '#add' do
    let(:path) { '/pages' }
    let(:page_options) do
      { to: 'page#index', scope_path: '/scope', via: 'GET' }
    end
    let(:options) { { via: 'GET', scope_path: '/scope' } }
    let(:block) { -> {} }
    let(:method) { 'GET' }

    context 'when params valid' do
      it 'adds route with GET method' do
        page_options[:via] = 'GET'
        subject.add(path, page_options, &block)
        expect(subject.routes['GET'].size).to eq 1
      end

      it 'adds route with PUT method' do
        page_options[:via] = 'PUT'
        subject.add(path, page_options, &block)
        expect(subject.routes['PUT'].size).to eq 1
      end

      it 'adds route with POST method' do
        page_options[:via] = 'POST'
        subject.add(path, page_options, &block)
        expect(subject.routes['POST'].size).to eq 1
      end

      it 'adds route with DELETE method' do
        page_options[:via] = 'DELETE'
        subject.add(path, page_options, &block)
        expect(subject.routes['DELETE'].size).to eq 1
      end

      it 'adds route with String path' do
        subject.add('/string', options, &block)
        expect(subject.routes[method].size).to eq 1
      end

      it 'adds route with Regexp path' do
        subject.add(/(test|eiger)/, options, &block)
        expect(subject.routes[method].size).to eq 1
      end

      it 'adds route with String class_name' do
        subject.add(path, options, &block)
        expect(subject.routes[method].size).to eq 1
      end
    end
  end

  describe '#method_name' do
    let(:method) { 'GET' }
    let(:path) { 'path' }
    let(:scope) { '/scope' }
    let(:result) { "#{method} #{scope} #{path}".to_sym }
    it 'returns Symbol class' do
      expect(subject.method_name(method, scope, path)).to be_kind_of(Symbol)
    end

    it 'returns "GET path"' do
      expect(subject.method_name(method, scope, path)).to eq result
    end
  end

  describe '#get_route' do
    let(:route) { MiniTest::Mock.new }
    let(:path) { 'path' }
    let(:fake_path) { 'fake_path' }
    let(:method) { 'GET' }

    context 'defined path' do
      it 'returns route' do
        route.expect(:match, true, [path])
        route.expect(:nil?, false, [])
        subject.routes[method] = [route]
        expect(subject.match(method, path)).not_to be_nil
      end
    end

    context 'undefined path' do
      it 'returns nil' do
        route.expect(:match, false, [fake_path])
        subject.routes[method] = [route]
        expect(subject.match(method, fake_path)).to be_nil
      end
    end
  end
end
