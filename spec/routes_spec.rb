# coding: UTF-8
# rubocop:disable RegexpLiteral
require 'spec_helper'

describe 'routes' do
  it '404s when no route found' do
    mock_request { get('/foo') {} }

    get('/bar')
    expect(status).to eq 404
  end

  it 'allows using unicode' do
    mock_request { get('/föö') {} }

    get('/f%C3%B6%C3%B6')
    expect(status).to eq 200
  end

  it 'handles encoded slashes correctly' do
    mock_request { get('/:a') { params[:a] } }

    get('/foo%2Fbar')
    expect(status).to eq 200
    expect(body).to eq 'foo/bar'
  end

  it 'exposes params with indifferent hash' do
    mock_request { get('/:foo') { params['foo'] + params[:foo] } }

    get('/bar')
    expect(body).to eq 'barbar'
  end

  it 'merges named params and query string params in params' do
    mock_request { get('/:foo') { params['foo'] + params['baz'] } }

    get('/bar?baz=biz')
    expect(body).to eq 'barbiz'
  end

  it 'supports named params like /hello/:person' do
    mock_request { get('/hello/:person') { "Hello #{params['person']}" } }

    get('/hello/Frank')
    expect(body).to eq 'Hello Frank'
  end

  it 'does not concatinate params with the same name' do
    mock_request { get('/:foo') { params[:foo] } }

    get('/a?foo=b')
    expect(body).to eq 'a'
  end

  it 'supports single splat params like /*' do
    mock_request do
      get('/*') do
        params['splat'].join "\n"
      end
    end

    get('/foo')
    expect(body).to eq 'foo'

    get('/foo/bar/baz')
    expect(body).to eq 'foo/bar/baz'
  end

  it 'supports mixing multiple splat params like /*/foo/*/*' do
    mock_request do
      get '/*/foo/*/*' do
        params['splat'].join ' '
      end
    end

    get('/bar/foo/bling/baz')
    expect(body).to eq 'bar bling baz'

    get '/bar/foo/baz'
    expect(status).to eq 404
  end

  it 'supports mixing named and splat params like /:foo/*' do
    mock_request { get('/:foo/*') {} }

    get('/foo/bar/baz')
    expect(status).to eq 200
  end

  it "matches a dot ('.') as part of a named param" do
    mock_request do
      get '/:foo/:bar' do
        params[:foo]
      end
    end

    get('/user@example.com/name')
    expect(status).to eq 200
    expect(body).to eq 'user@example.com'
  end

  it 'literally matches dot in paths' do
    mock_request { get('/test.bar') {} }

    get '/test.bar'
    expect(status).to eq 200
    get 'test0bar'
    expect(status).to eq 404
  end

  it 'literally matches dollar sign in paths' do
    mock_request { get('/test$/') {} }

    get '/test$/'
    expect(status).to eq 200
  end

  it '0' do
    mock_request do
      get '/:test' do
        params['test']
      end
    end

    get('/bob+ross')
    expect(status).to eq 200
    expect(body).to eq 'bob+ross'
  end

  it 'literally matches parens in paths' do
    mock_request { get('/test(bar)/') {} }

    get '/test(bar)/'
    expect(status).to eq 200
  end

  it 'supports basic nested params' do
    mock_request do
      get '/hi' do
        params['person']['name']
      end
    end

    get '/hi?person[name]=John+Doe'
    expect(status).to eq 200
    expect(body).to eq 'John Doe'
  end

  it 'exposes nested params with indifferent hash' do
    mock_request do
      get '/testme' do
        params['bar']['foo']
      end
    end

    get '/testme?bar[foo]=baz'
    expect(body).to eq 'baz'
  end

  it 'exposes params nested within arrays with indifferent hash' do
    mock_request do
      get '/testme' do
        params['bar'][0]['foo']
      end
    end

    get '/testme?bar[][foo]=baz'
    expect(status).to eq 200
    expect(body).to eq 'baz'
  end

  it 'supports arrays within params' do
    mock_request do
      get '/foo' do
        # assert_equal ['A', 'B'], params['bar']
        'looks good'
      end
    end

    get '/foo?bar[]=A&bar[]=B'
    expect(status).to eq 200
    expect(body).to eq 'looks good'
  end

  it 'preserves non-nested params' do
    mock_request do
      get '/foo' do
        'looks good'
      end
    end

    get('/foo?article_id=2&comment[body]=awesome')
    expect(status).to eq 200
    expect(body).to eq 'looks good'
  end

  it 'matches paths that include spaces encoded with %20' do
    mock_request do
      get '/path with spaces' do
        'looks good'
      end
    end

    get('/path%20with%20spaces')
    expect(status).to eq 200
    expect(body).to eq 'looks good'
  end

  it 'matches paths that include ampersands' do
    mock_request do
      get '/:name' do
        'looks good'
      end
    end

    get('/foo&bar')
    expect(status).to eq 200
    expect(body).to eq 'looks good'
  end

  it 'URL decodes named parameters and splats' do
    mock_request do
      get '/:foo/*' do
        nil
      end
    end

    get('/hello%20world/how%20are%20you')
    expect(status).to eq 200
  end

  it 'supports regular expressions' do
    mock_request do
      get(/^\/foo...\/bar$/) do
        'Hello World'
      end
    end

    get('/foooom/bar')
    expect(status).to eq 200
    expect(body).to eq 'Hello World'
  end

  it 'makes regular expression captures available in params[:captures]' do
    mock_request do
      get(/^\/fo(.*)\/ba(.*)/) do
        'right on'
      end
    end

    get('/foorooomma/baf')
    expect(status).to eq 200
    expect(body).to eq 'right on'
  end

  it 'raises a TypeError when pattern is not a String or Regexp' do
    expect { mock_request { get(83) {} } }.to raise_error(TypeError)
  end

  it 'scopes by Symbol namespace' do
    mock_request do
      namespace :scope do
        get('/foo') { 'bar' }
      end
    end

    get('/scope/foo')
    expect(status).to eq 200
    expect(body).to eq 'bar'
  end

  it 'scopes by string namespace' do
    mock_request do
      namespace '/scope' do
        get('/foo') { 'bar' }
      end
    end

    get('/scope/foo')
    expect(status).to eq 200
    expect(body).to eq 'bar'
  end

  it 'does not match regexp scope' do
    mock_request do
      namespace(/\/^[A-Z]+$/) do
        get('/foo') { 'bar' }
      end
    end

    get('/ABC/foo')
    expect(status).to eq 404
  end

  it 'returns page not found for invalid param' do
    mock_request do
      get('/:name') {}
    end

    get('/name/foo')
    expect(status).to eq 404
  end

  context 'namespace' do
    it 'matches param for scoped controller method' do
      mock_request do
        namespace :foo do
          route :bar, :test_app
        end
      end

      get('/foo/bar')
      expect(body).to eq 'index'

      get('/foo/bar/12')
      expect(body).to eq '12'
    end

    it 'matches param for scoped get method' do
      mock_request do
        namespace :foo do
          get '/bar/:name' do
            params[:name]
          end
        end
      end

      get('/foo/bar/test')
      expect(body).to eq 'test'
    end

    it 'matchs regexp scope' do
      mock_request do
        namespace(:scope) do
          get(%r{^/[A-Z]+$}) { 'bar' }
        end
      end

      get('/scope/ABC')
      expect(status).to eq 200
    end
  end
end
