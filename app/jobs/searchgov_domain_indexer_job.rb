class SearchgovDomainIndexerJob < ActiveJob::Base
  queue_as :searchgov
  attr_reader :searchgov_domain, :delay, :conditions, :start

  def perform(searchgov_domain:, delay:, conditions:, start: Time.now.utc.to_s)
    @searchgov_domain = searchgov_domain
    @delay = delay
    @conditions = conditions
    @start = start

    fetchable_urls.first&.fetch

    if fetchable_urls.any?
      SearchgovDomainIndexerJob.set(wait: delay.seconds).
        perform_later(searchgov_domain: searchgov_domain,
                      delay: delay,
                      conditions: conditions,
                      start: start)
    else
      searchgov_domain.done_indexing!
    end
  end

  private

  def fetchable_urls
    searchgov_domain.searchgov_urls.where(conditions).where(outdated)
  end

  def outdated
    ['last_crawled_at IS NULL OR last_crawled_at < ?', start]
  end
end
