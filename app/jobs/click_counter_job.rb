# frozen_string_literal: true

# Update click counts for popular URLs for a given domain
class ClickCounterJob < ActiveJob::Base
  queue_as :searchgov

  def perform(domain:)
    ClickCounter.new(domain: domain).update_click_counts
  end
end
