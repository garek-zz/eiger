module Eiger
  # Base class for Eiger gem
  class Base
    class << self
      def get(path, &block)
        route('GET', path, &block)
      end

      def route(request_method, path, &block)
        method_name = method_name(request_method, path)
        define_singleton_method(method_name, &block)
      end

      def method_name(request_method, path)
        "#{request_method} #{path}".to_sym
      end

      def call(env)
        request     = Rack::Request.new(env)
        method_name = method_name(request.request_method, request.fullpath)

        if respond_to?(method_name)
          [200, {}, [send(method_name)]]
        else
          [404, {}, ['Page not found']]
        end
      end
    end
  end
end
