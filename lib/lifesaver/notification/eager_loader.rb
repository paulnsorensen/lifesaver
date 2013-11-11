module Lifesaver
  module Notification
    class EagerLoader
      def initialize
        @models_to_load = {}
        @loaded_models = {}
      end

      def add_model(class_name, id)
        return if model_previously_added?(class_name, id)
        models_to_load[class_name] ||= []
        models_to_load[class_name] << id
        mark_model_added(class_name, id)
      end

      def load
        models = []
        models_to_load.each do |class_name, ids|
          klass = class_name.classify.constantize
          models |= load_associations(klass, ids)
          models_to_load.delete(class_name)
        end
        models
      end

      def empty?
        @models_to_load.empty?
      end

      private

      attr_accessor :models_to_load, :loaded_models

      def load_associations(klass, ids)
        klass.load_with_notifiable_associations(ids)
      end

      def model_previously_added?(class_name, id)
        loaded_models[class_name] && loaded_models[class_name][id]
      end

      def mark_model_added(class_name, id)
        loaded_models[class_name] ||= {}
        loaded_models[class_name][id] = true
      end
    end
  end
end
