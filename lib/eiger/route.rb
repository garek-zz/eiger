module Eiger
  # Route class
  class Route
    attr_reader :controller, :action, :path_manager

    def initialize(path, options, &block)
      @action         = options[:action]
      @controller     = options[:controller]
      scope_path      = options[:scope_path]
      @path_manager   = PathManager.new(path, scope_path)

      add_method(&block)
    end

    def call_method(request)
      params        = request.params
      route_params  = path_manager.params(request.path)

      params.merge!(route_params)
      params = Hash.indifferent_params(params)

      controller.new(params).send(action)
    end

    def match(fullpath)
      path_manager.match(fullpath)
    end

    private

    def add_method(&block)
      return unless path_manager.valid? && controller == Eiger::Controller

      controller.add_method(action, &block)
    end
  end
end
