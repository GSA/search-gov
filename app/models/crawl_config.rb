class CrawlConfig < ApplicationRecord
  serialize :allowed_domains, coder: JSON
  serialize :starting_urls, coder: JSON
  serialize :sitemap_urls, coder: JSON
  serialize :deny_paths, coder: JSON

  before_validation :normalize_domains_and_urls
  before_validation :initialize_empty_arrays

  validates :name, presence: true
  validates :allowed_domains, presence: true
  validates :starting_urls, presence: true
  validates :depth_limit, presence: true, numericality: { only_integer: true }
  validates :schedule, presence: true
  validates :output_target, presence: true, inclusion: { in: %w[endpoint elasticsearch] }

  validate :validate_schedule_format
  validate :validate_starting_urls
  validates :allowed_domains, uniqueness: { scope: :output_target, message: "and output target combination must be unique" }

  private

  def normalize_domains_and_urls
    # Sort and uniq arrays to ensure consistent representation for uniqueness validation
    self.allowed_domains.sort!.uniq! if allowed_domains.is_a?(Array)
    self.starting_urls.sort!.uniq! if starting_urls.is_a?(Array)
  end

  def initialize_empty_arrays
    self.sitemap_urls ||= []
    self.deny_paths ||= []
  end

  def validate_schedule_format
    return if schedule.blank?

    parts = schedule.split
    return if parts.length == 5 # Basic cron format is 5 parts

    errors.add(:schedule, "is not a valid cron expression. It must have 5 parts: minute, hour, day of month, month, day of week.")
  end

  def validate_starting_urls
    return if starting_urls.blank? || allowed_domains.blank?

    starting_urls.each do |url|
      begin
        uri = URI.parse(url)
        unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
          errors.add(:starting_urls, "contains an invalid URL (must be HTTP or HTTPS): #{url}")
          next
        end

        # Check if the URL's host or any of its parent domains matches an allowed domain.
        # This allows crawling `sub.domain.com` if `domain.com` is an allowed domain.
        unless allowed_domains.any? { |allowed_domain| uri.host == allowed_domain || uri.host.end_with?(".#{allowed_domain}") }
          errors.add(:starting_urls, "contains a URL (#{url}) that does not belong to any of the allowed domains")
        end
      rescue URI::InvalidURIError
        errors.add(:starting_urls, "contains a malformed URL: #{url}")
      end
    end
  end
end
