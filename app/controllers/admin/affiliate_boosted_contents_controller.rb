class Admin::AffiliateBoostedContentsController < Admin::AdminController
  active_scaffold :boosted_content do |config|
    config.label = 'Best Bets: Text'
    config.actions.exclude :create, :update
    config.list.columns =[:affiliate, :title, :status, :url, :publish_start_on, :publish_end_on]
    config.list.empty_field_text = ''

    config.actions.add :export
    config.export.columns = %i(title url description publish_start_on publish_end_on
                               boosted_content_keywords match_keyword_values_only status)

    config.actions.add :field_search
    config.field_search.columns = :affiliate_id, :title

    config.columns[:affiliate].label = 'Site'
    config.columns[:affiliate_id].label = 'Site ID'
  end

  def conditions_for_collection
    ['NOT ISNULL(affiliate_id)']
  end
end
