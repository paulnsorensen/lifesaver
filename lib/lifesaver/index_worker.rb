class Lifesaver::IndexWorker
  include ::Resque::Plugins::UniqueJob

  def self.queue; Lifesaver.config.indexing_queue end

  def self.perform(class_name, model_id, operation)
    Lifesaver::Indexing::Indexer.new(
                                     class_name: class_name,
                                     model_id: model_id,
                                     operation: operation
                                    ).perform
  end
end
