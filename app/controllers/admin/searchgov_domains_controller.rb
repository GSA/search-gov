# frozen_string_literal: true

class Admin::SearchgovDomainsController < Admin::AdminController
  before_action :find_searchgov_domain, only: %i[confirm_delete delete_domain reindex]

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
    config.action_links.add(
      'confirm_delete',
      label: 'Delete',
      type: :member,
      crud_type: :delete,
      method: :get,
      position: :after,
      inline: false
    )
    config.update.columns = %i[js_renderer]
    config.columns[:js_renderer].label = 'Render Javascript'
  end

  def confirm_delete
    render :delete_domain
  end

  def delete_domain
    if destroy_domain_confirmation_valid?
      enqueue_deletion_job
      flash_message(:success)
      redirect_to action: :index
    else
      flash_message(:error)
      redirect_to_show
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

  private

  def find_searchgov_domain
    @searchgov_domain = SearchgovDomain.find(params[:id])
  end

  def destroy_domain_confirmation_valid?
    params[:confirmation].casecmp('DESTROY DOMAIN').zero?
  end

  def enqueue_deletion_job
    SearchgovDomainDestroyerJob.perform_later(@searchgov_domain)
  end

  def flash_message(type)
    key = "flash_messages.searchgov_domains.delete.#{type}"
    message = I18n.t(key, domain: @searchgov_domain.domain)
    flash[type] = message
  end

  def redirect_to_show
    redirect_to action: :show, id: @searchgov_domain.id
  end
end
