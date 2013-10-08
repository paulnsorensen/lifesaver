module Lifesaver
  class IndexGraph
    def self.generate(models, verbose=false)
      models_to_index = []
      visited_models = {}
      graph = []
      models.each do |m|
        m.symbolize_keys!
        klass = m[:class].to_s.classify.constantize
        status = m[:status].to_sym
        if klass.exists?(m[:id])
          mdl = klass.find(m[:id])
          if status == :notified
            graph << mdl
          else # status == :changed
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
       if mdl.is_a?(Hash)
         klass = mdl[:class].to_s.classify.constantize
         mdl = klass.find(mdl[:id]) if klass.exists?(mdl[:id])
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