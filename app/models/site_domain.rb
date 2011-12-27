class SiteDomain < ActiveRecord::Base
  VALID_UPLOAD_FILE_CONTENT_TYPE = %w( text/csv text/comma-separated-values )

  before_validation :filter_domain
  validates_format_of :domain, :with => /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,3}(\/.*)?$/ix
  validates_uniqueness_of :domain, :scope => :affiliate_id
  before_save :set_site_name

  belongs_to :affiliate
  scope :ordered, {:order => 'domain ASC'}

  def self.process_file(affiliate, file)
    if file.blank? or !VALID_UPLOAD_FILE_CONTENT_TYPE.include? file.content_type
      return { :success => false, :error_message => 'Invalid file format; please upload a csv file (.csv).'}
    end

    site_domain_hash = ActiveSupport::OrderedHash.new
    FasterCSV.parse(file.read, :skip_blanks => true) do |row|
      site_domain_hash[row[0]] = row[1] unless row[0].blank?
    end
    added_site_domains = affiliate.add_site_domains(site_domain_hash)
    added_site_domains.count > 0 ? { :success => true, :added => added_site_domains.count } : { :success => false, :error_message => 'No domains uploaded; please check your file and try again.' }
  end

  protected
  def filter_domain
    self.domain = domain.gsub(/(https?:\/\/| )/, '').downcase unless domain.blank?
  end

  def set_site_name
    self.site_name = domain if site_name.blank?
  end
end
