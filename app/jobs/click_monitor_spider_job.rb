# frozen_string_literal: true

# Enqueues a ClickCounterJob for each SearchgovDomain in spider
class ClickMonitorSpiderJob < ApplicationJob
  queue_as :searchgov

  def perform
    SearchgovDomain.find_each do |searchgov_domain|
      ClickCounterJob.perform_later(domain: searchgov_domain.domain, index_name: ENV.fetch('SEARCHELASTIC_INDEX'))
    end
  end
end
