# Eiger Module
module Eiger
  # Base class for Eiger gem
  class Base
    attr_accessor :route, :request
    attr_reader :route_manager, :app

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
        path = path.to_s
        path = '/' + path unless path.start_with?('/')

        add_route('GET', path, to: "#{class_name}#index")
        add_route('GET', path + '/:id', to: "#{class_name}#show")
        add_route('PUT', path + '/:id', to: "#{class_name}#update")
        add_route('POST', path, to: "#{class_name}#create")
        add_route('DELETE', path + '/:id', to: "#{class_name}#destroy")
      end

      def namespace(path)
        @scope = Scope.new(path, scope)

        yield
      ensure
        @scope = scope.parent
      end

      def call(env)
        app.call!(env)
      end

      def route_manager
        @route_manager ||= RouteManager.new
      end

      private

      def scope
        @scope ||= Scope.new
      end

      def app
        @app ||= new
      end

      def add_route(method, *args, &block)
        path                  = args.first
        options               = args.extract_options!
        options[:via]         = method
        options[:scope_path]  = scope.absolute_path

        route_manager.add(path, options, &block)
      end
    end

    def routes
      self.class.route_manager
    end

    def call!(env)
      @request  = Rack::Request.new(env)
      @route    = routes.match(@request.request_method, @request.path)
      @response = Response.new(@route, @request)

      @response.process
      @response.finish
    end
  end

  def self.new(base = Base, &block)
    base = Class.new(base)
    base.class_eval(&block) if block_given?
    base
  end
end
