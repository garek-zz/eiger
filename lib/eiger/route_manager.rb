module Eiger
  # RouteManager class
  class RouteManager
    attr_accessor :routes

    def initialize
      @routes = {}
    end

    def add(path, options, &block)
      method              = options[:via]
      scope_path          = options[:scope_path]
      class_name, action  = options.fetch(:to, '').split('#')

      action ||= method_name(method, scope_path, path)

      options[:controller]  = Controller.get_child_or_self(class_name)
      options[:action]      = action.to_sym

      (routes[method] ||= []) << Route.new(path, options, &block)
    end

    def method_name(request_method, scope_path, path)
      "#{request_method} #{scope_path} #{path}".to_sym
    end

    def match(request_method, path)
      (@routes[request_method] || []).find do |route|
        route.match(path)
      end
    end
  end
end
