require 'spec_helper'

describe Eiger::Base, type: :controller do
  describe 'GET' do
    class TestApp < Eiger::Base
      get('/') { 'Hello World' }
    end

    let(:request) { Rack::MockRequest.new(TestApp) }

    it 'returns 200 status' do
      response = request.get('/')
      expect(response.status).to eq 200
    end

    it 'returns 404 status' do
      response = request.get('/test')
      expect(response.status).to eq 404
    end
  end
end
