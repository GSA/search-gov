# frozen_string_literal: true

# Updates I14yDocuments in the searchgov index with click_count data
# to be used for relevancy ranking
class ClickCounter
  SIGNIFICANT_PERCENTAGE = 75

  attr_reader :domain

  def initialize(domain:)
    @domain = domain
  end

  def update_click_counts
    statistically_significant_clicks.each do |click|
      update_click_count(url: click[0], count: click[1])
    end
  end

  private

  def statistically_significant_clicks
    query = DateRangeTopNFieldQuery.new(nil,
                                        1.month.ago,
                                        Time.current,
                                        'click_domain',
                                        domain,
                                        field: 'params.url', size: 0)

    RtuTopClicks.new(query.body, true).
      top_n_to_percentage(SIGNIFICANT_PERCENTAGE)
  end

  def update_click_count(url:, count:)
    searchgov_url = SearchgovUrl.find_by!(url: url)
    I14yDocument.update(document_id: searchgov_url.document_id,
                        click_count: count,
                        handle: 'searchgov')
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("SearchgovUrl not found for clicked URL: #{url}")
  rescue I14yDocument::I14yDocumentError => error
    Rails.logger.error(
      "Unable to update I14yDocument click_count for #{url}: #{error}"
    )
  end
end
