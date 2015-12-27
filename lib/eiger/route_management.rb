module Eiger
  # RouteManagement class
  class RouteManagement
    attr_accessor :routes

    HTTP_METHODS = %w(GET PUT POST DELETE)

    def initialize
      @routes = {}
    end

    def add(http_method, path, class_name = nil, action = nil, &block)
      return unless HTTP_METHODS.include?(http_method)

      action    = method_name(http_method, path) unless action
      klass     = Controller.get_child_or_self(class_name)
      route     = Route.new(path, klass, action, &block)

      (@routes[http_method] ||= []) << route if route.valid?
    end

    def method_name(request_method, path)
      "#{request_method} #{path}".to_sym
    end

    def get_route(request_method, path)
      @routes[request_method].find do |route|
        route.match_path(path)
      end
    end
  end
end
