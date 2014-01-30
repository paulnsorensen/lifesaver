module Lifesaver
  module Notification
    class Enqueuer
      def initialize(models)
        @serialized_models = models
      end

      def enqueue
        if should_enqueue?
          ::Resque.enqueue(Lifesaver::VisitorWorker, serialized_models)
        end
      end

      private

      attr_accessor :serialized_models

      def should_enqueue?
        !serialized_models.empty? && !Lifesaver.indexing_suppressed?
      end
    end
  end
end
