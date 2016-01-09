require 'rack/test'
require 'eiger'

def mock_app(&block)
  Eiger.new(&block)
end

def mock_request(&block)
  @request ||= Rack::MockRequest.new(mock_app(&block))
end

def get(*args)
  @response = @request.get(*args)
end

def request(*args)
  @response = @request.request(*args)
end

def status
  @response.status if @response.respond_to? :status
end

def body
  @response.body if @response.respond_to? :body
end

# class RegexpLookAlike
class RegexpLookAlike
  class MatchData
    def captures
      %w(this is a test)
    end
  end

  def match(string)
    ::RegexpLookAlike::MatchData.new if string == '/this/is/a/test/'
  end

  def keys
    %w(one two three four)
  end
end
