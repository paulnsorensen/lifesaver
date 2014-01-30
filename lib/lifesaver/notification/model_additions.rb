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
          before_destroy do
            send :load_associations, :destroy
          end
          after_commit do
            send :update_associations
          end
        end
      end

      def self.included(base)
        base.class_attribute :notifiable_associations
        base.notifiable_associations = NotifiableAssociations.new
        base.delegate :notifiable_associations, to: :class
        base.class_attribute :dependent_associations
        base.dependent_associations = DependentAssociations.new(base)
        base.delegate :dependent_associations, to: :class
        base.extend(ClassMethods)
      end

      def associations_to_notify
        models = []
        notifiable_associations.on_notify.each do |association|
          models |= models_for_association(association)
        end
        models
      end

      def needs_to_notify?
        notifiable_associations.any_to_notify?
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

      def update_associations
        operation = destroyed? ? :destroy : :update
        models = load_associations(operation)
        serialized_models = serialize_models(models)
        enqueue_worker(serialized_models)
        @loaded_associations = nil
      end

      def load_associations(operation)
        return @loaded_associations unless @loaded_associations.nil?
        @loaded_associations = []
        to_skip = operation == :destroy ? dependent_associations.fetch : []
        to_load = associations_to_load(:on_change, to_skip)
        to_load.each { |key| @loaded_associations |= models_for_association(key) }
        @loaded_associations
      end

      def associations_to_load(key, associations_to_skip)
        associations = notifiable_associations.public_send(key)
        associations - associations_to_skip
      end

      def serialize_models(models)
        serialized_models = []
        models.each do |m|
          serialized_models << Lifesaver::SerializedModel.new(m.class.name, m.id)
        end
        serialized_models
      end

      def enqueue_worker(serialized_models)
        Lifesaver::Notification::Enqueuer.new(serialized_models).enqueue
      end
    end
  end
end
