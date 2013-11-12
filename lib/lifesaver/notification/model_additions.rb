module Lifesaver
  module Notification
    module ModelAdditions
      module ClassMethods
        def notifies_for_indexing(*args)
          self.notifiable_associations = NotifiableAssociations.new
          options = args.last.is_a?(Hash) ? args.pop : {}
          notifiable_associations.populate(args, options)
          notification_callbacks
        end

        def load_with_notifiable_associations(ids)
          includes(notifiable_associations.on_notify).where(id: ids)
        end

        private

        def notification_callbacks
          after_save do
            send :update_associations, :update
          end
          before_destroy do
            send :update_associations, :destroy
          end
        end
      end

      def self.included(base)
        base.class_attribute :notifiable_associations
        base.notifiable_associations = NotifiableAssociations.new
        base.extend(ClassMethods)
      end

      def associations_to_notify
        models = []
        self.class.notifiable_associations.on_notify.each do |association|
          models |= models_for_association(association)
        end
        models
      end

      def needs_to_notify?
        self.class.notifiable_associations.any_to_notify?
      end

      def models_for_association(assoc)
        models = []
        association = send(assoc)
        unless association.nil?
          if association.respond_to?(:each)
            association.each do |m|
              models << m
            end
          else
            models << association
          end
        end
        models
      end

      private

      def update_associations(operation)  models = []
        to_skip = operation == :destroy ? dependent_associations : []
        to_load = associations_to_load(:on_change, to_skip)

        models = []
        to_load.each { |key| models |= models_for_association(key) }
        serialized_models = serialize_models(models)
        enqueue_worker(serialized_models)
      end

      def associations_to_load(key, skip_associations)
        associations = self.class.notifiable_associations.public_send(key)
        skip_associations_map = {}
        skip_associations.each { |assoc| skip_associations_map[assoc] = true }
        associations.reject { |assoc| skip_associations_map[assoc] }
      end

      def dependent_associations
        dependent_associations = []
        self.class.reflect_on_all_associations.each do |association|
          if association.options[:dependent].present?
            dependent_associations << association.name.to_sym
          end
        end
        dependent_associations
      end

      def serialize_models(models)
        serialized_models = []
        models.each do |m|
          serialized_models << Lifesaver::SerializedModel.new(m.class.name, m.id)
        end
        serialized_models
      end

      def enqueue_worker(serialized_models)
        ::Resque.enqueue(Lifesaver::VisitorWorker, serialized_models) unless serialized_models.empty?
      end

    end
  end
end
