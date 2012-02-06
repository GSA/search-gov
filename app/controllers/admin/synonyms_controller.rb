class Admin::SynonymsController < Admin::AdminController
  active_scaffold :synonym do |config|
    config.create.columns = [:phrase, :alias]
    config.list.columns = [:phrase, :alias, :source]
    config.list.sorting = { :phrase => :asc }
  end
end
