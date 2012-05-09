class Admin::FeaturesController < Admin::AdminController
  active_scaffold :features do |config|
    config.update.columns = [:display_name]
    config.actions.exclude :delete
    config.columns.exclude :affiliate_feature_addition
    config.list.columns.exclude :created_at, :updated_at
    config.create.columns.exclude :affiliates
    config.columns[:affiliates].form_ui = :select
    config.columns[:affiliates].associated_limit = 0
    actions.add :export
  end
end
