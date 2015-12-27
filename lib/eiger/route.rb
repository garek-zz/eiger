module Eiger
  # Route class
  class Route
    attr_reader :klass, :action, :path, :params, :path_segments

    def initialize(path, klass, action, &block)
      @action         = action.to_s.to_sym
      @klass          = klass
      @path           = path
      @path_segments  = path.split('/') if path.is_a?(String)
      @params         = {}

      init_controller_method(&block)
    end

    def call_method(request)
      match_params(request.fullpath)
      params.merge(request.params)

      klass.new(params).send(action)
    end

    def match_path(fullpath)
      if path.is_a?(Regexp)
        match_regexp_path(fullpath)
      elsif path.is_a?(String)
        match_string_path(fullpath)
      end
    end

    def valid?
      valid_path? && valid_klass? && valid_method?
    end

    private

    def match_regexp_path(fullpath)
      fullpath =~ path
    end

    def match_string_path(fullpath)
      segments = fullpath.split('/')

      path_segments.size == segments.size && match_path_segments(segments)
    end

    def match_path_segments(segments)
      path_segments.each.with_index.reduce(true) do |memo, (seg, i)|
        memo && ((seg =~ /^:\w/) || (seg == segments[i]))
      end
    end

    def valid_path?
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

    def valid_method?
      klass && klass.method_defined?(action)
    end

    def valid_klass?
      klass && (klass < Eiger::Controller || klass == Eiger::Controller)
    end

    def init_controller_method(&block)
      klass.add_method(action, &block) if add_method? && block_given?
    end

    def add_method?
      valid_klass? && !klass.method_defined?(action)
    end

    def match_params(fullpath)
      return if path.is_a?(Regexp)

      segments = fullpath.split('/')

      path_segments.each_with_index do |seg, i|
        params[seg[1..-1].to_sym] = segments[i] if seg =~ /:\w+/
      end
    end
  end
end
