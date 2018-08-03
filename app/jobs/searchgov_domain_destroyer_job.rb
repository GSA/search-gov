class SearchgovDomainDestroyerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(searchgov_domain:)
    searchgov_domain.searchgov_urls.find_each do |url|
      byebug
      url.destroy
    end
    # byebug
    SearchgovDomain.find(searchgov_domain.id).destroy
    # searchgov_domain.destroy
    # byebug
  end
end