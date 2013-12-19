module Lifesaver
  module Indexing
    class Indexer
      def initialize(args)
        @class_name = args.fetch(:class_name)
        @model_id = args.fetch(:model_id)
        @operation = args.fetch(:operation).to_sym
      end

      def perform
        case operation
        when :update
          store
        when :destroy
          remove
        end
      end

      private

      attr_reader :class_name, :model_id, :operation

      def index
        @index ||= Tire.index(klass.index_name)
      end

      def klass
        @klass ||= class_name.to_s.classify.constantize
      end

      def store
        index.store(klass.find(model_id)) if klass.exists?(model_id)
      end

      def remove
        index.remove(type: klass.document_type, id: model_id)
      end
    end
  end
end
