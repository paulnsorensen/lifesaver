module Lifesaver
  class IndexGraph

    def initialize(marshalled_models=[])
      @queue = []
      @visited_models = {}
      @models_to_index = []

      marshalled_models.each do |m|
        model, opts = Lifesaver::Marshal.load(m)
        if model
          if opts[:status] == :notified
            add_model(model)
          elsif opts[:status] == :changed
            visit_model(model)
            add_unvisited_models(model, :on_change)
          end
        end
      end
    end

    def generate
      while model = @queue.shift
        @models_to_index << model if model.has_index?
        add_unvisited_models(model, :on_notify)
      end
      @models_to_index
    end

    private

    def add_model(model)
      visit_model(model)
      @queue << model
    end

    def visit_model(model)
      @visited_models[visited_model_key(model)] = true
    end

    def model_visited?(model)
      @visited_models[visited_model_key(model)] || false
    end

    def add_unvisited_models(model, key)
      models = notified_models(model, key)
      models.each { |m| add_model(m) unless model_visited?(m) }
    end

    def visited_model_key(mdl)
      if mdl.is_a?(Hash)
        klass = mdl[:class].to_s.classify
        "#{klass}_#{mdl[:id]}"
      elsif mdl.try(:id)
        "#{mdl.class.name}_#{mdl.id}"
      end
    end

    def notified_models(mdl, key)
      if Lifesaver::Marshal.is_serialized?(mdl)
        mdl, opts = Lifesaver::Marshal.load(mdl)
      end
      models = []
      mdl.class.notifiable_associations[key].each do |assoc|
        models |= mdl.association_models(assoc)
      end
      models
    end

  end
end