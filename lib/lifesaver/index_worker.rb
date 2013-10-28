class Lifesaver::IndexWorker
  include ::Resque::Plugins::UniqueJob

  def self.queue; ::Lifesaver.config.indexing_queue end

  def self.perform(class_name, id, action)
    klass = class_name.to_s.classify.constantize
    case action.to_sym
    when :update
      klass.find(id).update_index if klass.exists?(id)
    when :destroy
      klass.index.remove({type: klass.document_type, id: id})
    end
  end
end