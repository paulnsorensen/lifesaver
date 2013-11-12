module Lifesaver
  module Indexing
    class Enqueuer
      def initialize(args)
        @model = args[:model]
        @operation = args[:operation]
      end

      def enqueue
        if should_enqueue?(model)
          ::Resque.enqueue(Lifesaver::IndexWorker, class_name, id, operation)
        end
      end

      private
      attr_accessor :model, :operation

      def should_enqueue?(model)
        model.should_index?
      end

      def class_name
        model.class.name.underscore.to_sym
      end

      def id
        model.id
      end
    end
  end
end
