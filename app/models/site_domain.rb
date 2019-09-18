class SiteDomain < ApplicationRecord
  include Dupable
  include SearchDomain

  VALID_UPLOAD_FILE_CONTENT_TYPE = %w(text/csv text/comma-separated-values application/vnd.ms-excel)
  MAX_DOCS_PER_CRAWL = 1000
  INVALID_FILE_FORMAT_MESSAGE = 'Invalid file format. Please upload a csv file (.csv).'
  BLACKLISTED_EXTENSION_REGEXP = Regexp.new("\.#{IndexedDocument::BLACKLISTED_EXTENSIONS.join('|')}$", true)
  validate :domain_coverage, if: Proc.new { |site_domain| site_domain.domain.present? and site_domain.affiliate.present? }
  before_save :set_site_name

  def self.process_file(affiliate, file)
    if file.blank? or !VALID_UPLOAD_FILE_CONTENT_TYPE.include? file.content_type
      return { :success => false, :error_message => INVALID_FILE_FORMAT_MESSAGE }
    end

    site_domain_hash = ActiveSupport::OrderedHash.new
    begin
      CSV.parse(file.read, :skip_blanks => true) do |row|
        site_domain_hash[row[0]] = row[1] unless row[0].blank?
      end
    rescue
      return { :success => false, :error_message => INVALID_FILE_FORMAT_MESSAGE }
    end
    added_site_domains = affiliate.add_site_domains(site_domain_hash)
    added_site_domains.count > 0 ? {:success => true, :added => added_site_domains.count} : {:success => false, :error_message => 'No domains uploaded; please check your file and try again.'}
  end

  protected

  def set_site_name
    self.site_name = domain if site_name.blank?
  end

  def domain_coverage
    existing = self.affiliate.site_domains.detect do |existing_site_domain|
      next if id == existing_site_domain.id
      UrlCoverage.overlap? existing_site_domain.domain, domain
    end
    errors.add(:base, "'#{self.domain}' is already covered by your existing site domain '#{existing.domain}'") if existing
  end
end
