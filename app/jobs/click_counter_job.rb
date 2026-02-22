# frozen_string_literal: true

# Update click counts for popular URLs for a given domain
class ClickCounterJob < ApplicationJob
  queue_as :searchgov

  def perform(domain:, index_name: nil)
    ClickCounter.new(domain: domain, index_name: index_name).update_click_counts
  end
end
