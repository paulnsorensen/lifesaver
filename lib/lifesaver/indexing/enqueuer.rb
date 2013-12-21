module Lifesaver
  module Indexing
    class Enqueuer
      def initialize(args)
        @model = args.fetch(:model)
        @operation = args.fetch(:operation)
      end

      def enqueue
        if should_enqueue?(model)
          ::Resque.enqueue(
                           Lifesaver::IndexWorker,
                           class_name,
                           model_id,
                           operation
                          )
        end
      end

      private

      attr_reader :model, :operation

      def should_enqueue?(model)
        model.should_index?
      end

      def class_name
        model.class.name.underscore.to_sym
      end

      def model_id
        model.id
      end
    end
  end
end
