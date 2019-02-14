# frozen_string_literal: true

# Update click counts for popular URLs for each SearchgovDomain
class ClickCounterJob < ActiveJob::Base
  queue_as :searchgov

  def perform
    SearchgovDomain.find_each do |searchgov_domain|
      ClickCounter.new(domain: searchgov_domain.domain).update_click_counts
    end
  end
end
