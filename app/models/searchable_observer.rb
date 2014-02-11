class SearchableObserver < ActiveRecord::Observer
  observe :featured_collection, :boosted_content, :indexed_document, :news_item

  def after_save(model)
    model_name = model.class.name
    elastic_klass = "Elastic#{model_name}".constantize
    data_klass = "Elastic#{model_name}Data".constantize
    data = data_klass.new(model)
    builder = data.to_builder
    elastic_klass.index(builder.attributes!.symbolize_keys) if builder
  end

  def after_destroy(model)
    "Elastic#{model.class.name}".constantize.delete(model.id)
  end
end