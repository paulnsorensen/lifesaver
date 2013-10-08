module Lifesaver
  class Marshal
    def dump()
    end

    def load()
    end

    def is_serialized?(obj)
      if obj.is_a?(Hash)
        obj.symbolize_keys
        if obj.key?(:class) && obj.key?(:id)
          return true
        end
      end
      false
    end
  end
end