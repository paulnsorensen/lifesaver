module Lifesaver
  class Marshal
    def self.dump(obj, opts={})
      raise unless opts.is_a?(Hash)
      opts[:class] = obj.class.name.underscore.to_sym
      opts[:id] = obj.id
      opts
    end

    def self.load(obj)
      raise unless self.is_serialized?(obj)
      obj = self.sanitize(obj)
      klass = obj[:class].to_s.classify.constantize
      if klass.exists?(obj[:id])
        mdl = klass.find(obj[:id])
        obj.delete(:id)
        obj.delete(:class)
        return mdl, obj
      else
        nil
      end
    end

    def self.sanitize(obj)
      raise unless obj.is_a?(Hash)
      obj = obj.symbolize_keys
      obj[:id] = obj[:id].to_i if obj[:id]
      obj[:class] = obj[:class].to_sym if obj[:class]
      obj[:status] = obj[:status].to_sym if obj[:status]
      obj
    end

    def self.is_serialized?(obj)
      if obj.is_a?(Hash)
        obj = self.sanitize(obj)
        if obj.key?(:class) && obj.key?(:id)
          return true
        end
      end
      false
    end
  end
end