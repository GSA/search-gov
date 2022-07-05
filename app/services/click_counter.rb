# frozen_string_literal: true

# Updates I14yDocuments in the searchgov index with click_count data
# to be used for relevancy ranking
class ClickCounter
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
                                        'click',
                                        1.month.ago,
                                        Time.current,
                                        'click_domain',
                                        domain,
                                        field: 'params.url',
                                        size: 3_000)

    RtuTopClicks.new(query.body, true).top_n
  end

  def update_click_count(url:, count:)
    searchgov_url = SearchgovUrl.find_by!(url: url)
    I14yDocument.update(document_id: searchgov_url.document_id,
                        click_count: count,
                        handle: 'searchgov')
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("SearchgovUrl not found for clicked URL: #{url}")
  rescue I14yDocument::I14yDocumentError => e
    Rails.logger.error(
      "Unable to update I14yDocument click_count for #{url}: #{e}"
    )
  end
end
