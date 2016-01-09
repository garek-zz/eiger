module Eiger
  # Response class
  class Response < Rack::Response
    attr_reader :route, :request

    def initialize(route, request)
      @route    = route
      @request  = request
      super()
    end

    def process
      return page_not_found unless @route

      @status = 200
      @body   = [@route.call_method(@request)]
    rescue Exception => e # rubocop:disable RescueException
      error_page(e)
    end

    def page_not_found
      @status = 404
      @body   = ['Page not found']
    end

    def error_page(e)
      @status = 500
      @body   = [e]
    end
  end
end
