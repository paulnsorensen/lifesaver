module Lifesaver
  module Model
    module IndexingNotification
      module ClassMethods

        def notifies_for_indexing(*args)
          self.notifiable_associations = { on_change: [], on_notify: [] }
          options = args.pop if args.last.is_a?(Hash)

          populate_notifiable_associations(:on_change, args)
          populate_notifiable_associations(:on_notify, args)

          if options.present?
            if options[:only_on_change].present?
              populate_notifiable_associations(:on_change, options[:only_on_change])
            end
            if options[:only_on_notify].present?
              populate_notifiable_associations(:on_notify, options[:only_on_notify])
            end
          end

          notification_callbacks
        end

        private

        def populate_notifiable_associations(key, associations)
          if associations.is_a?(Array)
            self.notifiable_associations[key] |= associations
          else
            self.notifiable_associations[key] << associations
          end
        end

        def notification_callbacks(options={})
          after_save do
            send :update_associations, options.merge(operation: :update)
          end
          before_destroy do
            send :update_associations, options.merge(operation: :destroy)
          end
        end
      end

      def self.included(base)
        base.class_attribute :notifiable_associations
        base.notifiable_associations = { on_change: [], on_notify: [] }
        base.extend(ClassMethods)
      end


      def association_models(assoc)
        models = []
        association = public_send(assoc.to_sym)
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

      def dependent_association_map
        dependent = {}
        self.class.reflect_on_all_associations.each do |assoc|
          dependent[assoc.name.to_sym] = true if assoc.options[:dependent].present?
        end
        dependent
      end

      def update_associations(options)
        models = []
        if options[:operation] == :destroy
          dependent = dependent_association_map
          assoc_models = []
          self.class.notifiable_associations[:on_change].each do |assoc|
            assoc_models |= association_models(assoc) unless dependent[assoc]
          end
          assoc_models.each do |m|
            models << Lifesaver::Marshal.dump(m, {status: :notified})
          end
        elsif options[:operation] == :update
          models << Lifesaver::Marshal.dump(self, {status: :changed})
        end

        ::Resque.enqueue(Lifesaver::VisitorWorker, models) unless models.empty?
      end
    end
  end
end
