module Lifesaver
  module ModelAdditions
    module ClassMethods

      def notifies_for_indexing(*args)
        self.notifiable_associations = { on_change: [], on_notify: [] }
        opts = args.pop if args.last.is_a?(Hash)
        args.each do |a|
          self.notifiable_associations[:on_change] << a
          self.notifiable_associations[:on_notify] << a
        end
        %w(on_change on_notify).each do |k|
          opt = opts[("only_" + k).to_sym] if opts
          key = k.to_sym
          if opt
            if opt.is_a?(Array)
              self.notifiable_associations[key] |= opt
            else
              self.notifiable_associations[key] << opt
            end
          end
        end
      end

      def enqueues_indexing(options = {})
        if options[:on]
        else
          after_save do
            send :enqueue_indexing, options.merge(operation: :update)
            send :update_associations, options.merge(operation: :update)
          end
          before_destroy do
            send :update_associations, options.merge(operation: :destroy)
          end
          after_destroy do
            send :enqueue_indexing, options.merge(operation: :destroy)
          end
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
       association = send(assoc.to_sym)
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
          self.id,
          opts[:operation]
        )
      end
    end

    def update_associations(opts)
      models = []
      if opts[:operation] == :destroy
        to_be_deleted = {}
        self.class.reflect_on_all_associations.each do |assoc|
          to_be_deleted[assoc.name.to_sym] if assoc.options[:dependent].present?
        end
        assoc_models = []
        self.class.notifiable_associations[:on_change].each do |assoc|
          unless to_be_deleted[assoc]
            assoc_models |= association_models(assoc)
          end
        end
        assoc_models.each do |m|
          models << {class: m.class.name.underscore.to_sym, id: m.id, status: :notified}
        end
      elsif opts[:operation] == :update
        models << {class: self.class.name.underscore.to_sym, id: self.id, status: :changed}
      end
      # Since enqueue expects a splat of arguments, we need to put our array into an array
      ::Resque.enqueue(Lifesaver::VisitorWorker, models) unless models.empty?
    end

    def validate_options(options)
      # on: should only have active model callback verbs (create, update, destroy?)
      # after: (next versions after you use resque scheduler) time to schedule
      # only: specifies fields that trigger changes
    end

    def suppress_indexing?
      Lifesaver.indexing_suppressed? || @indexing_suppressed || false
    end

  end
end