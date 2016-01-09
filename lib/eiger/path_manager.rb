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
      path = URI.unescape(path.dup)

      match_scope(path) && match_path(path.sub(scope_path, ''))
    end

    def valid?
      if path_pattern.is_a? String
        valid_string?
      elsif path_pattern.is_a? Regexp
        true
      else
        fail TypeError, path_pattern
      end
    end

    def params(path)
      return {} if path_pattern.is_a?(Regexp)

      segments = path.split('/')

      path_segments.each_with_index.each_with_object({}) do |(seg, i), params|
        seg.match(/(:\w+)|(\*)/) do
          if $1
            params[seg[1..-1].to_s] = URI.unescape(segments[i])
          elsif $2
            (params['splat'] ||= []) << splat_param(segments, i)
          end
        end
      end
    end

    private

    def splat_param(segments, index)
      if path_segments.size == index + 1
        URI.unescape(segments[index..-1].join('/'))
      else
        URI.unescape(segments[index])
      end
    end

    # VALIDATION METHODS

    def valid_string?
      fail TypeError, path_pattern unless path_pattern =~ /^\//

      path_pattern[1..-1].split('/').all? do |segment|
        valid_segment?(segment)
      end
    end

    def valid_segment?(segment)
      URI.encode(segment).match(/((:\w+)|(\w+)|(\*))/) do
        ($1 && $1 == segment) || ($2 && $2 == segment) || $3
      end
    end

    # MATCH PATH METHODS

    def match_path(path)
      if path_pattern.is_a?(Regexp)
        match_regexp_path(path)
      elsif path_pattern.is_a?(String)
        match_string_path(path)
      end
    end

    def match_scope(path)
      path.start_with?(scope_path)
    end

    def match_regexp_path(path)
      path =~ path_pattern
    end

    def match_string_path(path)
      segments = path.split('/')

      (path_segments.size != 0 || segments.size == path_segments.size) &&
        match_path_segments(segments)
    end

    def match_path_segments(segments)
      path_segments.each.with_index.reduce(true) do |memo, (seg, i)|
        memo && ((seg =~ /^:\w|\*/ && !segments[i].nil?) || seg == segments[i])
      end
    end
  end
end
