module Eiger
  # class PathManager
  class PathManager
    class << self
      def init(path, scope_path = '')
        return StringPath.new(path, scope_path) if path.is_a?(String)
        return RegexpPath.new(path, scope_path) if path.is_a?(Regexp)

        fail TypeError, 'Invalid path type, allowed only String or Regexp type!'
      end

      def valid?(path)
        return path.match("[/[:[^\/]+|[^\/]+|\*]]*") if path.is_a? String
        return true if path.is_a? Regexp

        fail TypeError, 'Path must be String or Regexp type'
      end
    end
  end

  # class RegexpPath
  class RegexpPath
    attr_reader :pattern, :scope_path

    def initialize(path, scope_path = '')
      @scope_path = Regexp.new(scope_path)
      @pattern    = path
    end

    def match(path)
      unscoped_path(path).match(@pattern)
    end

    def params(path)
      r = unscoped_path(path).match(@pattern)

      params = {}

      r.names.each do |name|
        params[name] = URI.unescape(r[name])
      end if r

      params
    end

    protected

    def unscoped_path(path)
      path.sub(@scope_path, '')
    end
  end

  # class StringPath
  class StringPath < RegexpPath
    attr_reader :splat_pattern

    def initialize(path, scope_path = '')
      @pattern        = regexp_path(path)
      @splat_pattern  = regexp_splat(path)
      super(pattern, scope_path)
    end

    def params(path)
      params = super(path)

      # match params * from path to 'splat' variable
      rr = unscoped_path(path).match(@splat_pattern)
      params['splat'] = rr.captures.map { |p| p } if rr

      params
    end

    private

    def escape(path)
      URI.escape(path).gsub(/(\(|\)|\$|\.)/) { |r| Regexp.escape(r) }
    end

    # Prepare regexp for params like :name, :foo, :bar
    def regexp_path(path)
      path = escape(path)
      pre_path = path.gsub('*', '.*').gsub(%r{/\:([^\/]+)}, '/(?<\1>[^\/]+)')
      Regexp.new("^#{pre_path}$")
    end

    # Prepare regexp for params * type
    def regexp_splat(path)
      path = escape(path)
      pre_path = path.gsub('*', '(.*)').gsub(%r{/\:([^\/]+)}, '/[^\/]+')
      Regexp.new("^#{pre_path}$")
    end
  end
end
