# frozen_string_literal: true

class SearchgovDomainReindexerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain:)
    searchgov_domain.searchgov_urls.ok.in_batches.update_all(enqueued_for_reindex: true)
    searchgov_domain.index_sitemaps
  end
end
