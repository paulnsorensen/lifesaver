class Lifesaver::IndexWorker
  include ::Resque::Plugins::UniqueJob
  @queue = :lifesaver_indexing
  def self.perform(class_name, id, action)
    klass = class_name.to_s.classify.constantize
    case action.to_sym
    when :update
      if klass.exists?(id)
        klass.find(id).update_index
      end
    when :remove
      klass.index.remove({type: klass.document_type, id: id})
    end
  end
end