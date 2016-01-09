module Eiger
  # Controller class
  class Controller
    attr_accessor :params
    def initialize(params)
      @params = params
    end

    class << self
      def get_child_or_self(class_name = nil)
        return self if class_name.nil?

        klass = Object.const_get(class_name.to_s.camelize)
        klass if klass < Eiger::Controller
      end

      def add_method(action, &block)
        define_method(action, &block)
      end
    end
  end
end
