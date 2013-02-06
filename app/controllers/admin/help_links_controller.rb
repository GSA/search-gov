class Admin::HelpLinksController < Admin::AdminController
  active_scaffold :help_link do |config|
    config.list.columns.exclude :created_at, :updated_at
    config.columns[:request_path].description = 'For example: https://search.usa.gov/affiliates/1/preview'
  end
end