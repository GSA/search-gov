# frozen_string_literal: true

class SitemapMonitorJob < ApplicationJob
  queue_as :sitemap

  def perform
    SearchgovDomain.not_ok.each(&:check_status)
    SearchgovDomain.ok.each(&:index_sitemaps)
  end
end
