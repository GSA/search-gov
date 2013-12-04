class SearchableObserver < ActiveRecord::Observer
  observe :featured_collection

  def after_save(model)
    model_name = model.class.name
    elastic_klass = "Elastic#{model_name}".constantize
    data_klass = "Elastic#{model_name}Data".constantize
    data = data_klass.new(model)
    builder = data.to_builder
    elastic_klass.index(builder.attributes!.symbolize_keys)
  end

  def after_destroy(model)
    ElasticFeaturedCollection.delete(model.id)
  end
end