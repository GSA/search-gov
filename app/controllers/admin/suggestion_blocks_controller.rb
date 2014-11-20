class Admin::SuggestionBlocksController < Admin::AdminController
  active_scaffold :suggestion_block do |config|
    config.label = 'Query Terms Blocked from Showing Spelling Suggestions'
    config.columns = [:query]
    config.list.sorting = { :query => :asc }
  end
end