# frozen_string_literal: true

class Admin::SearchgovDomainsController < Admin::AdminController
  active_scaffold :searchgov_domain do |config|
    config.label = 'Search.gov Domains'
    config.actions = %i[create update list search export nested]
    config.create.columns = [:domain]
    config.columns = %i[
      id domain canonical_domain status activity
      urls_count unfetched_urls_count created_at
    ]
    config.nested.add_link(:searchgov_urls, label: 'URLs', page: false)
    config.nested.add_link(:sitemaps, page: false)
    config.action_links.add(
      'reindex',
      label: 'Reindex',
      type: :member,
      crud_type: :update,
      method: :post,
      position: false,
      inline: true,
      confirm: 'Are you sure you want to reindex this entire domain?'
    )

    update_columns = %i[
      js_renderer
    ]
    config.update.columns = []
    enable_disable_column_regex = /^(is_|js_renderer)/.freeze
    config.update.columns.add_subgroup 'Enable/Disable Settings' do |name_group|
      name_group.add *update_columns.select { |column| column =~ enable_disable_column_regex }
      name_group.collapsed = true
    end
  end

  def after_create_save(record)
    flash[:info] = "#{record.domain} has been created. Sitemaps will automatically begin indexing."
  end

  def reindex
    process_action_link_action do |searchgov_domain|
      SearchgovDomainReindexerJob.perform_later(searchgov_domain: searchgov_domain)

      flash[:info] = "Reindexing has been enqueued for #{searchgov_domain.domain}"
    end
  end
end
