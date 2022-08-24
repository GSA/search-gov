# frozen_string_literal: true

class SitemapMonitorJob < ApplicationJob
  queue_as :sitemap

  def perform
    SearchgovDomain.not_ok.find_each(&:check_status)
    SearchgovDomain.ok.find_each(&:index_sitemaps)
  end
end
