module Eiger
  # rubocop:disable PerlBackrefs,RegexpLiteral
  # class PathManager
  class PathManager
    attr_reader :path_pattern, :scope_path, :path_segments, :params

    def initialize(path, scope_path = '')
      @path_pattern   = path
      @scope_path     = scope_path
      @path_segments  = path.split('/') if path.is_a?(String)
    end

    def match(path)
      subpath = unscope_path(path)

      match_scope(path) && match_path(subpath)
    end

    def valid?
      if path_pattern.is_a? String
        valid_string?
      elsif path_pattern.is_a? Regexp
        true
      else
        fail TypeError, 'Path must be String or Regexp type'
      end
    end

    def params(path)
      return {} if path_pattern.is_a?(Regexp)

      path = unscope_path(path)
      segments = prepare_segments(path)
      segments_param(segments)
    end

    private

    def unscope_path(path)
      path.sub(scope_path, '')
    end

    def segments_param(segments)
      path_segments.each_with_index.each_with_object({}) do |(seg, i), params|
        seg.match(/(:\w+)|(\*)/) do
          params[seg[1..-1].to_s] = URI.unescape(segments[i]) if $1
          (params['splat'] ||= []) << segments[i] if $2
        end
      end
    end

    def prepare_segments(path)
      if path_segments.last =~ /\*$/
        segments = path.split('/', path_segments.size)
      else
        segments = path.split('/')
      end

      segments.map { |segment| URI.unescape(segment) }
    end

    def valid_string?
      fail TypeError, "Path must starts with '/'" unless path_pattern =~ /^\//

      path_pattern[1..-1].split('/').all? do |segment|
        valid_segment?(segment)
      end
    end

    def valid_segment?(segment)
      URI.encode(segment).match(/((:\w+)|(\w+)|(\*))/) do
        ($1 && $1 == segment) || ($2 && $2 == segment) || $3
      end
    end

    def match_path(path)
      if path_pattern.is_a?(Regexp)
        path =~ path_pattern
      elsif path_pattern.is_a?(String)
        segments = prepare_segments(path)

        segments.size == path_segments.size && match_path_segments(segments)
      end
    end

    def match_scope(path)
      path = URI.unescape(path.dup)
      path.start_with?(scope_path)
    end

    def match_path_segments(segments)
      path_segments.each.with_index.reduce(true) do |memo, (seg, i)|
        memo && ((seg =~ /^:\w|\*/ && !segments[i].nil?) || seg == segments[i])
      end
    end
  end
end
