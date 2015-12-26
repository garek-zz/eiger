module Eiger
  # Base class for Eiger gem
  class Base
    class << self
      def get(path, &block)
        route('GET', path, &block)
      end

      def route(request_method, path, &block)
        return unless valid_path?(path)

        method_name = method_name(request_method, path)
        define_singleton_method(method_name, &block)
        add_route(request_method, path)
      end

      def add_route(request_method, path)
        @routes ||= {}
        @routes[request_method] ||= []
        @routes[request_method] << path
      end

      def method_name(request_method, path)
        "#{request_method} #{path}".to_sym
      end

      def get_route(request_method, path)
        @routes[request_method].find do |route|
          if route.is_a?(String)
            match_method(route, path)
          elsif route.is_a?(Regexp)
            path =~ route
          end
        end
      end

      def match_method(route, path)
        path_segments   = path.split('/')
        route_segments  = route.split('/')
        method          = route

        return nil if path_segments.size != route_segments.size

        route_segments.each_with_index do |segment, i|
          if (segment.empty? || segment =~ /w+/) && segment != path_segments[i]
            method = nil
          end
        end

        method
      end

      def match_params(route, path)
        return {} if route.is_a? Regexp

        path_segments   = path.split('/')
        route_segments  = route.split('/')
        params          = {}

        route_segments.each_with_index do |segment, i|
          params[segment[1..-1].to_sym] = path_segments[i] if segment =~ /:\w+/
        end

        params
      end

      def valid_path?(path)
        if path.is_a? String
          path.split('/').none? do |seg|
            seg.match(/:\w+|\w+/) && seg.match(/:\w+|\w+/)[0] != seg
          end
        elsif path.is_a? Regexp
          true
        else
          fail TypeError
        end
      end

      def params
        @params ||= match_params(@route, @path)
      end

      def call(env)
        @request = Rack::Request.new(env)
        @path    = @request.fullpath
        @route   = get_route(@request.request_method, @path)

        if @route
          method_name = method_name(@request.request_method, @route)

          [200, {}, [send(method_name)]]
        else
          [404, {}, ['Page not found']]
        end
      end
    end
  end
end
