module Eiger
  # Controller class
  class Controller
    attr_accessor :params
    def initialize(params)
      @params = params
    end

    class << self
      def index_path(path)
        "#{path}s"
      end

      def show_path(path)
        "#{path}/:id"
      end

      def update_path(path)
        "#{path}/:id"
      end

      def create_path(path)
        path
      end

      def destroy_path(path)
        "#{path}/:id"
      end

      def get_childe_or_self(class_name)
        return self unless class_name

        name = class_name.to_s.split('_').map(&:capitalize).join
        klass = Object.const_get(name)
        klass < Eiger::Controller ? klass : nil
      rescue NameError
        nil
      end

      def add_method(action, &block)
        define_method(action, &block)
      end
    end
  end
end
