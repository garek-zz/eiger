module Eiger
  # class Scope
  class Scope
    attr_reader :path, :parent

    def initialize(path = '', parent = nil)
      @path   = path.to_s
      @parent = parent
    end

    def absolute_path
      if parent
        File.join(parent.absolute_path, path)
      else
        path
      end
    end
  end
end
