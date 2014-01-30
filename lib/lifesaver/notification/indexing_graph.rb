module Lifesaver
  module Notification
    class IndexingGraph
      def initialize
        @queue = Lifesaver::Notification::TraversalQueue.new
        @loader = Lifesaver::Notification::EagerLoader.new
        @models_to_index = []
      end

      def initialize_models(serialized_models)
        serialized_models.each do |model_hash|
          model = Lifesaver::SerializedModel.new
          model.class_name = model_hash['class_name']
          model.id = model_hash['id']
          add_model_to_loader(model.class_name, model.id)
        end
      end

      def generate
        loop do
          if queue_full?
            model = pop_model
            models_to_index << model if model_should_be_indexed?(model)
            add_unvisited_associations(model)
          elsif loader_full?
            load_into_queue
          else
            break
          end
        end
        models_to_index
      end

      private

      attr_accessor :queue, :loader, :models_to_index

      def loader_full?
        !loader.empty?
      end

      def queue_full?
        !queue.empty?
      end

      def pop_model
        queue.pop
      end

      def push_model(model)
        queue << model
      end

      def add_model_to_loader(class_name, id)
        loader.add_model(class_name, id)
      end

      def load_models
        loader.load
      end

      def load_into_queue
        load_models.each { |model| queue << model }
      end

      def model_should_be_indexed?(model)
        model.has_index?
      end

      def load_associations_for_model(model)
        model.associations_to_notify
      end

      def model_needs_to_notify?(model)
        model.needs_to_notify?
      end

      def add_unvisited_associations(model)
        models = load_associations_for_model(model)
        models.each do |m|
          if model_needs_to_notify?(model)
            add_model_to_loader(m.class.name, m.id)
          else
            push_model(model)
          end
        end
      end
    end
  end
end
