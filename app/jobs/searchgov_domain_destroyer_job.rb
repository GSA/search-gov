class SearchgovDomainDestroyerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain)
    ActiveRecord::Base.transaction do
      searchgov_domain.searchgov_urls.find_each do |url|
        url.destroy!
      end
      searchgov_domain.destroy!
    end
  end
end
