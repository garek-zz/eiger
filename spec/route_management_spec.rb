require 'minitest/autorun'
require 'spec_helper'

describe Eiger::RouteManagement do
  before do
    class Page < Eiger::Controller
      def index; end
    end
  end

  describe '#add' do
    context 'input http_method' do
      let(:path) { '/' }
      let(:block) { -> {} }

      it 'adds route with GET method' do
        subject.add('GET', path, &block)
        expect(subject.routes['GET'].size).to eq 1
      end

      it 'adds route with PUT method' do
        subject.add('PUT', path, &block)
        expect(subject.routes['PUT'].size).to eq 1
      end

      it 'adds route with POST method' do
        subject.add('POST', path, &block)
        expect(subject.routes['POST'].size).to eq 1
      end

      it 'adds route with DELETE method' do
        subject.add('DELETE', path, &block)
        expect(subject.routes['DELETE'].size).to eq 1
      end

      it 'ignores with TEST method' do
        subject.add('TEST', path, &block)
        expect(subject.routes.size).to eq 0
      end
    end

    context 'input path' do
      let(:method) { 'GET' }
      let(:block) { -> {} }

      it 'adds route with String type' do
        subject.add(method, 'string', &block)
        expect(subject.routes[method].size).to eq 1
      end

      it 'adds route with Regexp type' do
        subject.add(method, %r{/(test|eiger)/}, &block)
        expect(subject.routes[method].size).to eq 1
      end

      it 'raises TypeError for Fixnum type' do
        expect { subject.add(method, 0, &block) }.to raise_error(TypeError)
      end
    end

    context 'input class_name' do
      let(:method) { 'GET' }
      let(:action) { :index }
      let(:path) { '/pages' }

      it 'adds route with String type' do
        subject.add(method, path, 'page', action)
        expect(subject.routes[method].size).to eq 1
      end

      it 'adds route with Symbol type' do
        subject.add(method, path, :page, action)
        expect(subject.routes[method].size).to eq 1
      end

      it 'ignore with Fixnum type' do
        subject.add(method, path, 0, action)
        expect(subject.routes.size).to eq 0
      end
    end

    context 'input action' do
      let(:method) { 'GET' }
      let(:klass) { :page }
      let(:path) { '/pages' }

      it 'adds route with String type' do
        subject.add(method, path, klass, 'index')
        expect(subject.routes[method].size).to eq 1
      end

      it 'adds route with Symbol type' do
        subject.add(method, path, klass, :index)
        expect(subject.routes[method].size).to eq 1
      end

      it 'ignore with Fixnum type' do
        subject.add(method, path, klass, 234)
        expect(subject.routes.size).to eq 0
      end

      it 'ignore with missing method' do
        subject.add(method, path, klass, :test)
        expect(subject.routes.size).to eq 0
      end
    end
  end

  describe '#method_name' do
    let(:method) { 'GET' }
    let(:path) { 'path' }

    it 'returns Symbol class' do
      expect(subject.method_name(method, path)).to be_kind_of(Symbol)
    end

    it 'returns "GET path"' do
      expect(subject.method_name(method, path)).to eq "#{method} #{path}".to_sym
    end
  end

  describe '#get_route' do
    let(:route) { MiniTest::Mock.new }
    let(:path) { 'path' }
    let(:fake_path) { 'fake_path' }
    let(:method) { 'GET' }

    it 'returns route for defined path' do
      route.expect(:match_path, true, [path])
      route.expect(:nil?, false, [])
      subject.routes[method] = [route]
      expect(subject.get_route(method, path)).not_to be_nil
    end

    it 'returns nil without route for path' do
      route.expect(:match_path, false, [fake_path])
      subject.routes[method] = [route]
      expect(subject.get_route(method, fake_path)).to be_nil
    end
  end
end
