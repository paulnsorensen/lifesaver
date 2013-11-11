module Lifesaver
  module Notification
    class TraversalQueue
      def initialize
        @visited_models = {}
        @queue = []
      end

      def size
        queue.size
      end

      def push(model)
        return if model_visited?(model)
        visit_model(model)
        queue << model
      end

      def <<(model)
        push(model)
      end

      def pop
        queue.shift
      end

      def empty?
        queue.empty?
      end

      private

      attr_accessor :queue, :visited_models

      def visit_model(model)
        visited_models[model_key(model)] = true
      end

      def model_visited?(model)
        visited_models[model_key(model)] || false
      end

      def model_key(model)
        "#{model.class.name}_#{model.id}"
      end
    end
  end
end