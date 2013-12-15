module TireHelper
  def setup_indexes(models)
    @class_buckets = {}
    bucketize_models(models)
    refresh_indexes
  end

  private

  attr_accessor :class_buckets

  def bucketize_models(models)
    models.each do |model|
      add_model_to_bucket(model)
    end
  end

  def add_model_to_bucket(model)
    key = model.class.name
    class_buckets[key] ||= []
    class_buckets[key] << model
  end

  def refresh_indexes
    class_buckets.each do |class_name, models|
      refresh_index(class_name, models)
    end
  end

  def refresh_index(class_name, models)
    klass = class_name.constantize
    klass.tire.index.delete
    klass.tire.create_elasticsearch_index
    models.each { |model| model.tire.update_index }
    klass.tire.index.refresh
  end
end
