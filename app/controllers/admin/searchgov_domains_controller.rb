# frozen_string_literal: true

class Admin::SearchgovDomainsController < Admin::AdminController
  before_action :set_searchgov_domain, only: %i[confirm_delete delete_domain]

  active_scaffold :searchgov_domain do |config|
    config.label = 'SearchGov Domains'
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
      'stop_indexing',
      confirm:   'Are you sure you want to stop indexing this domain?',
      crud_type: :update,
      inline:    true,
      label:     'stop indexing',
      method:    :post,
      position:  false,
      type:      :member
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

  def stop_indexing
    process_action_link_action do |searchgov_domain|
      searchgov_domain.stop_indexing!

      flash[:info] = t(:'.indexing_stopped', name: searchgov_domain.domain)
    end
  end

  def confirm_delete
    render :delete_domain
  end

  def delete_domain
    if destroy_domain_confirmation_valid?
      enqueue_deletion_job
      flash[:success] = I18n.t('flash_messages.searchgov_domains.delete.success', domain: @searchgov_domain.domain)
      redirect_to admin_searchgov_domains_path
    else
      flash[:error] = I18n.t('flash_messages.searchgov_domains.delete.error')
      redirect_to_show
    end
  end

  def after_create_save(record)
    flash[:info] = "#{record.domain} has been created. Sitemaps will automatically begin indexing."
  end

  def reindex
    process_action_link_action do |searchgov_domain|
      SearchgovDomainReindexerJob.perform_later(searchgov_domain: searchgov_domain)
      searchgov_domain.update(status: SearchgovDomain::INDEXING_STARTED)
      flash[:info] = "Reindexing has been enqueued for #{searchgov_domain.domain}."
    end
  end

  private

  def set_searchgov_domain
    @searchgov_domain = SearchgovDomain.find(params[:id])
  end

  def destroy_domain_confirmation_valid?
    params[:confirmation].casecmp('DESTROY DOMAIN').zero?
  end

  def enqueue_deletion_job
    SearchgovDomainDestroyerJob.perform_later(@searchgov_domain)
  end

  def redirect_to_show
    redirect_to action: :show, id: @searchgov_domain.id
  end
end
