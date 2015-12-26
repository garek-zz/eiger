require 'spec_helper'

describe Eiger::Base, type: :controller do
  describe 'GET' do
    class TestApp < Eiger::Base
      get('/') {}
      get('/name/:name') { params[:name] }
      get(%r{^\/regexp$}) {}
    end

    let(:request) { Rack::MockRequest.new(TestApp) }

    context 'String route' do
      it 'returns 200 status' do
        response = request.get('/')
        expect(response.status).to eq 200
      end

      it 'returns 200 status with params' do
        response = request.get('/name/hello')
        expect(response.status).to eq 200
      end

      it 'returns params :name' do
        response = request.get('/name/hello')
        expect(response.body).to eq 'hello'
      end

      context 'path whithout param' do
        it 'returns 404 status' do
          response = request.get('/name/')
          expect(response.status).to eq 404
        end
      end

      it 'returns 404 status' do
        response = request.get('/test')
        expect(response.status).to eq 404
      end
    end

    context 'Regexp route' do
      it 'returns 200 status' do
        response = request.get('/regexp')
        expect(response.status).to eq 200
      end

      it 'returns 404 status' do
        response = request.get('/Regexp')
        expect(response.status).to eq 404
      end
    end
  end

  describe '#get_route' do
    let(:base) { Eiger::Base }

    context 'String path' do
      let(:path) { '/name/:name' }

      before do
        base.add_route('GET', path)
      end

      it 'returns route' do
        expect(base.get_route('GET', '/name/hello')).to eq path
      end

      it 'returns nil' do
        expect(base.get_route('GET', '/name/')).to eq nil
      end
    end

    context 'Regexp path' do
      let(:path) { %r{^\/(name|test)$} }

      before do
        base.add_route('GET', path)
      end

      it 'returns route' do
        expect(base.get_route('GET', '/name')).to eq path
      end

      it 'returns nil' do
        expect(base.get_route('GET', '/names')).to eq nil
      end
    end
  end
end
