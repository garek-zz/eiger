module Eiger
  # Base class for Eiger gem
  class Base
    class << self
      def get(path, &block)
        add_route('GET', path, &block)
      end

      def post(path, &block)
        add_route('POST', path, &block)
      end

      def put(path, &block)
        add_route('PUT', path, &block)
      end

      def delete(path, &block)
        add_route('DELETE', path, &block)
      end

      def route(path, class_name)
        add_route('GET', Controller.index_path(path), class_name, :index)
        add_route('GET', Controller.show_path(path), class_name, :show)
        add_route('PUT', Controller.update_path(path), class_name, :update)
        add_route('POST', Controller.create_path(path), class_name, :create)
        add_route('DELETE', Controller.destroy_path(path), class_name, :destroy)
      end

      def call(env)
        new(@routes).call!(env)
      end

      def add_route(http_method, path, class_name = nil, action = nil, &block)
        @routes ||= RouteManagement.new
        @routes.add(http_method, path, class_name, action, &block)
      end
      private :add_route
    end

    def initialize(routes)
      @routes = routes
    end

    def call!(env)
      @request  = Rack::Request.new(env)
      @route    = @routes.get_route(@request.request_method, @request.fullpath)

      if @route
        [200, {}, [@route.call_method(@request)]]
      else
        [404, {}, ['Page not found']]
      end
    end
  end
end
