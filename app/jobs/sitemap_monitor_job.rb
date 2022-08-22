# frozen_string_literal: true

class SitemapMonitorJob < ApplicationJob
  queue_as :sitemap

  def perform
    SearchgovDomain.ok.find_each(&:index_sitemaps)
    SearchgovDomain.not_ok.find_each(&:check_status)
  end
end
