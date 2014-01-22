class Admin::SynonymsController < Admin::AdminController
  active_scaffold :synonym do |config|
    config.label = 'Synonyms for Elasticsearch Indexes'
    config.list.sorting = { entry: :asc }
    config.columns[:locale].form_ui = :select
    config.columns[:locale].options = { :options => [['English','en'],['Spanish','es']] }
    config.columns[:status].form_ui = :select
    config.columns[:status].options = { :options => Synonym::STATES }
  end
end
