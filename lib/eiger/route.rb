module Eiger
  # Route class
  class Route
    attr_reader :controller, :action, :path_manager

    def initialize(path, options, &block)
      @action         = options[:action]
      @controller     = options[:controller]
      scope_path      = options[:scope_path]
      @path_manager   = PathManager.init(path, scope_path)

      add_method(&block) if PathManager.valid?(path)
    end

    def call_method(request)
      params = prepare_params(request)

      controller.new(params).send(action)
    end

    def prepare_params(request)
      params        = request.params
      route_params  = path_manager.params(request.path)

      params.merge!(route_params)
      Hash.indifferent_params(params)
    end

    def match(fullpath)
      path_manager.match(fullpath)
    end

    private

    def add_method(&block)
      controller.add_method(action, &block) if controller == Eiger::Controller
    end
  end
end
