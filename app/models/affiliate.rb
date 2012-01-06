require 'sass/css'

class Affiliate < ActiveRecord::Base
  validates_presence_of :display_name, :name, :search_results_page_title, :staged_search_results_page_title, :locale
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :within=> (2..33)
  validates_format_of :name, :with=> /^[a-z0-9._-]+$/
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES, :message => 'must be selected'
  has_and_belongs_to_many :users
  belongs_to :affiliate_template
  belongs_to :staged_affiliate_template, :class_name => 'AffiliateTemplate'
  has_many :boosted_contents, :dependent => :destroy
  has_many :sayt_suggestions, :dependent => :destroy
  has_many :superfresh_urls, :dependent => :destroy
  has_many :popular_urls, :dependent => :destroy
  has_many :featured_collections, :dependent => :destroy
  has_many :indexed_documents, :dependent => :destroy
  has_many :rss_feeds, :dependent => :destroy
  has_many :excluded_urls, :dependent => :destroy
  has_many :sitemaps, :dependent => :destroy
  has_many :top_searches, :dependent => :destroy, :order => 'position ASC', :limit => 5
  has_many :site_domains, :dependent => :destroy
  validates_associated :popular_urls
  after_destroy :remove_boosted_contents_from_index
  validate :validate_css_property_hash, :validate_header_footer_css
  before_create :set_uses_one_serp
  before_save :set_default_theme, :set_default_affiliate_template, :ensure_http_prefix, :set_css_properties, :set_header_footer_sass
  before_validation :set_default_name, :set_default_search_results_page_title, :set_default_staged_search_results_page_title, :on => :create
  after_validation :update_error_keys
  after_create :normalize_site_domains
  scope :ordered, {:order => 'display_name ASC'}
  attr_writer :css_property_hash, :staged_css_property_hash
  attr_protected :uses_one_serp, :header_footer_sass, :staged_header_footer_sass

  accepts_nested_attributes_for :site_domains, :reject_if => :all_blank

  USAGOV_AFFILIATE_NAME = 'usasearch.gov'
  VALID_RELATED_TOPICS_SETTINGS = %w{ affiliate_enabled global_enabled disabled }
  DEFAULT_SEARCH_RESULTS_PAGE_TITLE = "{Query} - {SiteName} Search Results"

  HUMAN_ATTRIBUTE_NAME_HASH = {
    :display_name => "Site name",
    :name => "Site Handle (visible to searchers in the URL)",
    :staged_search_results_page_title => "Search results page title"
  }

  FONT_FAMILIES = ['Arial, sans-serif', 'Helvetica, sans-serif', '"Trebuchet MS", sans-serif', 'Verdana, sans-serif',
                   'Georgia, serif', 'Times, serif']

  THEMES = ActiveSupport::OrderedHash.new
  THEMES[:default] = { :display_name => 'Liberty Bell',
                       :left_tab_text_color => '#9E3030',
                       :title_link_color => '#2200CC',
                       :visited_title_link_color => '#800080',
                       :description_text_color => '#000000',
                       :url_link_color => '#008000' }
  THEMES[:elegant] = { :display_name => 'Gettysburg',
                       :left_tab_text_color => '#C71D2E',
                       :title_link_color => '#336699',
                       :visited_title_link_color => '#8F5576',
                       :description_text_color => '#595959',
                       :url_link_color => '#007F00' }
  THEMES[:fun_blue] = { :display_name => 'Virgin Islands',
                        :left_tab_text_color => '#87CB00',
                        :title_link_color => '#0CA5D8',
                       :visited_title_link_color => '#A972AB',
                       :description_text_color => '#444444',
                       :url_link_color => '#3DB7E0' }
  THEMES[:gray] = { :display_name => 'Mount Rushmore',
                    :left_tab_text_color => '#A10000',
                    :title_link_color => '#555555',
                    :visited_title_link_color => '#854268',
                    :description_text_color => '#595959',
                    :url_link_color => '#2C5D80' }
  THEMES[:natural] = { :display_name => 'Grand Canyon',
                       :left_tab_text_color => '#B58100',
                       :title_link_color => '#B58100',
                       :visited_title_link_color => '#008EB5',
                       :description_text_color => '#333333',
                       :url_link_color => '#B58100' }
  THEMES[:custom] = { :display_name => 'Custom' }

  DEFAULT_CSS_PROPERTIES = { :font_family => FONT_FAMILIES[0] }.merge(THEMES[:default])

  def name=(name)
    new_record? ? (write_attribute(:name, name)) : (raise "This field cannot be changed.")
  end

  def domains_as_array(reload = false)
    @domains_as_array ||= site_domains(reload).ordered.collect { |site_domain| site_domain.domain }
  end

  def scope_ids_as_array
    @scope_ids_as_array ||= (self.scope_ids.nil? ? [] : self.scope_ids.split(',').each{|scope| scope.strip!})
  end

  def has_multiple_domains?
    site_domains.count > 1
  end

  def includes_domain?(domain)
    domains_as_array.detect{ |affiliate_domain| domain =~ /#{Regexp.escape(affiliate_domain)}/i }.nil? ? false : true
  end
  
  def is_affiliate_related_topics_enabled?
    (self.related_topics_setting != 'global_enabled' && self.related_topics_setting != 'disabled') || self.related_topics_setting.nil?
  end

  def is_global_related_topics_enabled?
    self.related_topics_setting == 'global_enabled'
  end

  def is_related_topics_disabled?
    self.related_topics_setting == 'disabled'
  end

  def template
    affiliate_template.presence || AffiliateTemplate.default_template
  end

  def update_attributes_for_staging(attributes)
    attributes[:has_staged_content] = true
    self.update_attributes(attributes)
  end

  def update_attributes_for_current(attributes)
    attributes.merge!(:previous_header => self.header, :previous_footer => self.footer)
    %w{ header_footer_css header footer affiliate_template_id search_results_page_title favicon_url external_css_url theme css_properties css_property_hash }.each do |field|
      attributes[field.to_sym] = attributes["staged_#{field}".to_sym] if attributes.include?("staged_#{field}".to_sym)
    end
    attributes[:has_staged_content] = false
    self.update_attributes(attributes)
  end

  def build_search_results_page_title(query)
    build_page_title self.search_results_page_title, query
  end

  def build_staged_search_results_page_title(query)
    build_page_title self.staged_search_results_page_title, query
  end

  def build_page_title(page_title, query)
    query_string = query.blank? ? '' : query
    page_title = page_title.gsub(/\{query\}/i, query_string)
    page_title.gsub(/\{sitename\}/i, self.display_name)
  end

  def staging_attributes
    {
      :staged_header_footer_css => self.staged_header_footer_css,
      :staged_header => self.staged_header,
      :staged_footer => self.staged_footer,
      :staged_affiliate_template_id => self.staged_affiliate_template_id,
      :staged_search_results_page_title => self.staged_search_results_page_title,
      :staged_favicon_url => self.staged_favicon_url,
      :staged_external_css_url => self.staged_external_css_url,
      :staged_theme => self.staged_theme,
      :staged_css_properties => self.staged_css_properties
    }
  end

  def push_staged_changes
    self.update_attributes_for_current(self.staging_attributes)
  end

  def cancel_staged_changes
    self.update_attributes({
      :staged_header_footer_css => self.header_footer_css,
      :staged_header => self.header,
      :staged_footer => self.footer,
      :staged_affiliate_template_id => self.affiliate_template_id,
      :staged_search_results_page_title => self.search_results_page_title,
      :staged_favicon_url => self.favicon_url,
      :staged_external_css_url => self.external_css_url,
      :staged_theme => self.theme,
      :staged_css_properties => self.css_properties,
      :has_staged_content => false
    })
  end

  def sync_staged_attributes
    self.cancel_staged_changes unless self.has_staged_content?
  end

  def active_rss_feeds
    rss_feeds.where(:is_active => true)
  end

  def has_active_rss_feeds?
    active_rss_feeds.count > 0
  end

  def is_image_search_enabled?
    self.is_image_search_enabled
  end

  def has_changed_header_or_footer
    self.header != self.previous_header or self.footer != self.previous_footer
  end

  class << self
    def human_attribute_name(attribute_key_name, options = {})
      HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
    end
  end

  def css_property_hash
    if self.theme.to_sym == :custom
      @css_property_hash ||= (css_properties.blank? ? {} : JSON.parse(css_properties, :symbolize_keys => true))
    else
      @css_property_hash ||= css_properties.blank? ? THEMES[self.theme.to_sym] : THEMES[self.theme.to_sym].merge(JSON.parse(css_properties, :symbolize_keys => true))
    end
  end

  def staged_css_property_hash
    if self.staged_theme.to_sym == :custom
      @staged_css_property_hash ||= (staged_css_properties.blank? ? {} : JSON.parse(staged_css_properties, :symbolize_keys => true))
    else
      @staged_css_property_hash ||= staged_css_properties.blank? ? THEMES[self.staged_theme.to_sym] : THEMES[self.staged_theme.to_sym].merge(JSON.parse(staged_css_properties, :symbolize_keys => true))
    end
  end

  def active_top_searches
    self.top_searches.all(:conditions => 'NOT ISNULL(query)')
  end

  def add_site_domains(site_domain_param_hash)
    site_domain_hash = existing_site_domain_hash
    transaction do
      site_domain_param_hash.each do |domain, site_name|
        site_domain = site_domains.build(:domain => domain, :site_name => site_name)
        site_domain_hash[site_domain.domain] = site_domain if site_domain.valid?
      end
      normalize_site_domains site_domain_hash
    end
  end

  def update_site_domain(site_domain, site_domain_attributes)
    transaction do
      normalize_site_domains if site_domain.update_attributes(site_domain_attributes)
    end
  end

  def normalize_site_domains(site_domain_hash = existing_site_domain_hash)
    added_or_updated_site_domains = []
    domain_list = site_domain_hash.keys.sort { |a, b| a.length == b.length ? (a <=> b) : (a.length <=> b.length) }
    while (domain_list.length > 0)
      site_domain = site_domain_hash[domain_list.first]

      added_or_updated_site_domains << site_domain if site_domain.new_record? and site_domain.save

      domain_list = domain_list.drop(1).delete_if do |domain|
        if  domain.start_with?(domain_list.first) or domain.include?(".#{domain_list.first}")
          site_domain = site_domain_hash[domain]
          site_domain.destroy unless site_domain.new_record?
          true
        else
          false
        end
      end
    end
    added_or_updated_site_domains
  end

  def is_agency_govbox_enabled?
    is_agency_govbox_enabled
  end

  def is_medline_govbox_enabled?
    is_medline_govbox_enabled
  end

  private

  def remove_boosted_contents_from_index
    boosted_contents.each { |bs| bs.remove_from_index }
  end

  def set_default_affiliate_template
    return if self.uses_one_serp?
    self.staged_affiliate_template_id = AffiliateTemplate.default_id if staged_affiliate_template_id.blank?
    self.affiliate_template_id = AffiliateTemplate.default_id if affiliate_template_id.blank?
  end

  def set_default_name
    if self.name.blank?
      self.name = self.display_name.downcase.gsub(/[^a-z0-9._-]/, '')[0, 33] unless self.display_name.blank?
      self.name = nil if !self.name.blank? and self.name.length < 3
      self.name = nil if !self.name.blank? and Affiliate.find_by_name(self.name)
      self.name = Digest::MD5.hexdigest("#{Time.now.to_s}")[0..8] if self.name.blank?
    end
  end

  def set_default_search_results_page_title
    self.search_results_page_title = DEFAULT_SEARCH_RESULTS_PAGE_TITLE if self.search_results_page_title.blank?
  end

  def set_default_staged_search_results_page_title
    self.staged_search_results_page_title = DEFAULT_SEARCH_RESULTS_PAGE_TITLE if self.staged_search_results_page_title.blank?
  end

  def ensure_http_prefix
    self.favicon_url = "http://#{self.favicon_url}" unless self.favicon_url.blank? or self.favicon_url =~ %r{^http(s?)://}i
    self.staged_favicon_url = "http://#{self.staged_favicon_url}" unless self.staged_favicon_url.blank? or self.staged_favicon_url =~ %r{^http(s?)://}i
    self.external_css_url = "http://#{self.external_css_url}" unless self.external_css_url.blank? or self.external_css_url =~ %r{^http(s?)://}i
    self.staged_external_css_url = "http://#{self.staged_external_css_url}" unless self.staged_external_css_url.blank? or self.staged_external_css_url =~ %r{^http(s?)://}i
  end

  def validate_css_property_hash
    unless @css_property_hash.blank?
      validate_font_family @css_property_hash
      validate_color_in_css_property_hash @css_property_hash
    end
    unless @staged_css_property_hash.blank?
      validate_font_family @staged_css_property_hash
      validate_color_in_css_property_hash @staged_css_property_hash
    end
  end

  def validate_font_family(hash)
    errors.add(:base, "Font family selection is invalid") if hash['font_family'].present? and !FONT_FAMILIES.include?(hash['font_family'])
  end

  def validate_color_in_css_property_hash(hash)
    unless hash.blank?
      DEFAULT_CSS_PROPERTIES.keys.each do |key|
        next unless key.to_s =~ /color$/
        value = hash[key.to_s]
        next if value.blank?
        errors.add(:base, "#{key.to_s.humanize} should consist of a # character followed by 3 or 6 hexadecimal digits") unless value =~ /^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$/
      end
    end
  end

  def set_css_properties
    self.css_properties = @css_property_hash.to_json unless @css_property_hash.blank?
    self.staged_css_properties = @staged_css_property_hash.to_json unless @staged_css_property_hash.blank?
  end

  def set_uses_one_serp
    self.uses_one_serp = true if self.uses_one_serp.nil?
  end

  def set_header_footer_sass
    self.staged_header_footer_sass = parse_css(staged_header_footer_css) unless staged_header_footer_css.blank?
    self.header_footer_sass = parse_css(header_footer_css) unless header_footer_css.blank?
  end

  def validate_header_footer_css
    begin
      parse_css(header_footer_css)
      parse_css(staged_header_footer_css)
    rescue Sass::SyntaxError => err
      errors.add(:base, "CSS for the top and bottom of your search results page: #{err}")
    end
  end

  def parse_css(css)
    return if css.blank?
    sass_values = Sass::CSS.new(css).render(:sass).split("\n")
    sass_values.collect { |sass_value| "  #{sass_value}" }.join("\n")
  end

  def existing_site_domain_hash
    Hash[site_domains(true).collect { |current_site_domain| [current_site_domain.domain, current_site_domain] }]
  end

  def update_error_keys
    if self.errors.include?(:"site_domains.domain")
      error_value = self.errors.delete(:"site_domains.domain")
      self.errors.add(:domain, error_value)
    end
  end

  def set_default_theme
    if uses_one_serp?
      self.theme = THEMES.keys.first.to_s if theme.blank?
      self.staged_theme = THEMES.keys.first.to_s if staged_theme.blank?
    end
  end
end
