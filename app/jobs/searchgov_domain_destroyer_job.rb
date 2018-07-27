class SearchgovDomainDestroyerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(searchgov_domain:)
    searchgov_domain.searchgov_urls.find_each do |url|
      # byebug
      url.destroy!
    end
    searchgov_domain.destroy!
  end
end