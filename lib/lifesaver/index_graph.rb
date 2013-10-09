module Lifesaver
  class IndexGraph
    def self.generate(marshalled_models)
      models_to_index = []
      visited_models = {}
      graph = []
      marshalled_models.each do |m|
        mdl, opts = Lifesaver::Marshal.load(m)
        if mdl
          if opts[:status] == :notified
            graph << mdl
          elsif opts[:status] == :changed
            visited_models[self.visited_model_key(mdl)] = true
            graph |= self.notified_models(mdl, true)
          end
        end
      end
      graph.each {|m| visited_models[self.visited_model_key(m)] = true }
      while !graph.empty?
        mdl = graph.shift
        models_to_index << mdl if mdl.has_index?
        self.notified_models(mdl).each do |m|
          unless visited_models[self.visited_model_key(m)]
            visited_models[self.visited_model_key(m)] = true
            graph << m
          end
        end
      end
      models_to_index
     end

     def self.visited_model_key(mdl)
       if mdl.is_a?(Hash)
         klass = mdl[:class].to_s.classify
         "#{klass}_#{mdl[:id]}"
       elsif mdl.try(:id)
         "#{mdl.class.name}_#{mdl.id}"
       end
     end

     def self.notified_models(mdl, on_change = false)
       if Lifesaver::Marshal.is_serialized?(mdl)
         mdl, opts = Lifesaver::Marshal.load(mdl)
       end
       models = []
       key = on_change ? :on_change : :on_notify
       mdl.class.notifiable_associations[key].each do |assoc|
         models |= mdl.association_models(assoc)
       end
       models
     end
  end
end