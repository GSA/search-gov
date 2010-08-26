class Admin::SpotlightKeywordsController < Admin::AdminController
  active_scaffold :spotlight_keyword do |config|
    config.list.per_page = 100
  end
end