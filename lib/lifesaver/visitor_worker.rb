class Lifesaver::VisitorWorker
  include Resque::Plugins::UniqueJob
  @queue = :lifesaver_notification
  def self.perform(models)
    Lifesaver::IndexGraph.generate(models).each do |m|
      Resque.enqueue(Lifesaver::IndexWorker, m.class.name.underscore.to_sym, m.id, :update) if m.has_index?
    end
  end
end