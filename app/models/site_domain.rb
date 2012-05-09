class SiteDomain < ActiveRecord::Base
  VALID_UPLOAD_FILE_CONTENT_TYPE = %w( text/csv text/comma-separated-values )
  MAX_DOCS_PER_CRAWL = 2000

  before_validation :normalize_domain
  validates_presence_of :domain
  validates_format_of :domain, :with => /^([a-z0-9]+)?([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,3}(\/[^?.]*)?$/ix
  validates_uniqueness_of :domain, :scope => :affiliate_id
  validate :domain_coverage, :if => Proc.new { |site_domain| site_domain.affiliate.present? }
  before_save :set_site_name

  belongs_to :affiliate

  scope :ordered, {:order => 'domain ASC'}

  def self.process_file(affiliate, file)
    if file.blank? or !VALID_UPLOAD_FILE_CONTENT_TYPE.include? file.content_type
      return {:success => false, :error_message => 'Invalid file format; please upload a csv file (.csv).'}
    end

    site_domain_hash = ActiveSupport::OrderedHash.new
    FasterCSV.parse(file.read, :skip_blanks => true) do |row|
      site_domain_hash[row[0]] = row[1] unless row[0].blank?
    end
    added_site_domains = affiliate.add_site_domains(site_domain_hash)
    added_site_domains.count > 0 ? {:success => true, :added => added_site_domains.count} : {:success => false, :error_message => 'No domains uploaded; please check your file and try again.'}
  end

  def populate
    get_frontier.each do |link|
      indexed_document = affiliate.indexed_documents.create(:url => link)
      indexed_document.fetch if indexed_document
    end
  end

  def get_frontier(max_docs = MAX_DOCS_PER_CRAWL)
    return [] if domain.starts_with('.')
    start_page, queue, robots, frontier = "http://#{domain}/", [], {}, Set.new
    parsed_start_page_url = URI.parse(start_page)
    marked = Set.new [start_page]
    queue.push start_page
    while queue.any? and frontier.size < max_docs
      url = queue.pop
      begin
        current_url = URI.parse(url)
        next if url_disallowed?(current_url, robots)
        file = open(url)
        next unless file.content_type =~ /html/
        get_links_from_html_file(file, current_url, parsed_start_page_url).each do |link|
          unless marked.include?(link)
            queue.push link
            marked.add link
          end
        end
        frontier.add url
      rescue Exception => e
        Rails.logger.warn "Trouble fetching #{url}: #{e}"
      end
    end
    frontier.sort
  end

  def url_disallowed?(current_url, robots)
    robots[current_url.host] = Robot.update_for(current_url.host) unless robots.has_key?(current_url.host)
    robots[current_url.host].present? and robots[current_url.host].disallows?(current_url.path)
  end

  def get_links_from_html_file(file, current_url, parsed_start_page_url)
    doc = Nokogiri::HTML(file)
    links = doc.css('a').collect do |hlink|
      hlink['href'].squish.gsub(/#.*/, '') rescue nil
    end.uniq.compact.collect do |link|
      link_url = URI.parse(link) rescue nil
      if link_url.present?
        link_url = current_url.merge(link_url) if link_url.relative?
        link_url.to_s if link_url.scheme == "http" and link_url.host =~ /#{parsed_start_page_url.host}/i and link_url.path =~ /#{parsed_start_page_url.path}/i and link_url != current_url and !link_url.to_s.include?('?')
      end
    end
    links.uniq.compact
  end

  def to_label
    domain
  end

  protected
  def normalize_domain
    self.domain = domain.gsub(/(^https?:\/\/| |\/$)/, '').downcase unless domain.blank?
  end

  def set_site_name
    self.site_name = domain if site_name.blank?
  end

  def domain_coverage
    existing = self.affiliate.site_domains.detect do |existing_site_domain|
      self.domain != existing_site_domain.domain and (self.domain.start_with?(existing_site_domain.domain) or self.domain.include?(".#{existing_site_domain.domain}"))
    end
    errors.add(:base, "'#{self.domain}' is already covered by your existing site domain '#{existing.domain}'") if existing
  end
end
