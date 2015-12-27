require 'spec_helper'

describe Eiger::Controller, type: :controller do
  class Page < Eiger::Controller
    def index
      'index'
    end

    def show
      'show'
    end

    def create
      'create'
    end

    def update
      'update'
    end

    def destroy
      'destroy'
    end
  end

  class TestApp < Eiger::Base
    route('/page', :page)
  end

  let(:request) { Rack::MockRequest.new(TestApp) }

  describe '#index' do
    it 'returns 200 status' do
      response = request.get('/pages')
      expect(response.status).to eq 200
    end

    it 'returns hello text' do
      response = request.get('/pages')
      expect(response.body).to eq 'index'
    end
  end

  describe '#show' do
    it 'returns 200 status' do
      response = request.get('/page/12')
      expect(response.status).to eq 200
    end

    it 'returns hello text' do
      response = request.get('/page/12')
      expect(response.body).to eq 'show'
    end

    it 'returns 404 status' do
      response = request.get('/page/')
      expect(response.status).to eq 404
    end
  end

  describe '#create' do
    it 'returns 200 status' do
      response = request.post('/page')
      expect(response.status).to eq 200
    end

    it 'returns hello text' do
      response = request.post('/page')
      expect(response.body).to eq 'create'
    end
  end

  describe '#update' do
    it 'returns 200 status' do
      response = request.put('/page/12')
      expect(response.status).to eq 200
    end

    it 'returns hello text' do
      response = request.put('/page/12')
      expect(response.body).to eq 'update'
    end

    it 'returns 404 status' do
      response = request.put('/page')
      expect(response.status).to eq 404
    end
  end

  describe '#destroy' do
    it 'returns 200 status' do
      response = request.delete('/page/12')
      expect(response.status).to eq 200
    end

    it 'returns hello text' do
      response = request.delete('/page/12')
      expect(response.body).to eq 'destroy'
    end

    it 'returns 404 status' do
      response = request.delete('/page')
      expect(response.status).to eq 404
    end
  end
end
