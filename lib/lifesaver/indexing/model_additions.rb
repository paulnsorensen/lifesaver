module Lifesaver
  module Indexing
    module ModelAdditions
      module ClassMethods
        def enqueues_indexing
          indexing_callbacks
        end

        private

        def indexing_callbacks(options = {})
          # after_commit?
          after_save do
            send :enqueue_indexing, options.merge(operation: :update)
          end
          after_destroy do
            send :enqueue_indexing, options.merge(operation: :destroy)
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      def has_index?
        self.respond_to?(:tire)
      end

      def suppress_indexing
        @indexing_suppressed = true
      end

      def unsuppress_indexing
        @indexing_suppressed = false
      end

      private

      def enqueue_indexing(opts)
        if has_index? && !suppress_indexing?
          ::Resque.enqueue(
            Lifesaver::IndexWorker,
            self.class.name.underscore.to_sym,
            id,
            opts[:operation]
          )
        end
      end

      def suppress_indexing?
        Lifesaver.indexing_suppressed? || @indexing_suppressed || false
      end
    end
  end
end
