# frozen_string_literal: true

# Enqueues a ClickCounterJob for each SearchgovDomain
class ClickMonitorJob < ActiveJob::Base
  queue_as :searchgov

  def perform
    SearchgovDomain.find_each do |searchgov_domain|
      ClickCounterJob.perform_later(domain: searchgov_domain.domain)
    end
  end
end
