class SearchgovDomainPreparerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(searchgov_domain:)
    searchgov_domain.check_status
    searchgov_domain.index_sitemaps
  end
end
