class Lifesaver::VisitorWorker
  include Resque::Plugins::UniqueJob

  def self.queue; Lifesaver.config.notification_queue end

  def self.perform(models)
    indexing_graph = Lifesaver::Notification::IndexingGraph.new
    indexing_graph.initialize_models(models)
    indexing_graph.generate.each do |m|
      ::Resque.enqueue(Lifesaver::IndexWorker,
                        m.class.name.underscore.to_sym,
                        m.id,
                        :update) if m.has_index?
    end
  end
end
