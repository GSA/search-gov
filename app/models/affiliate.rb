class Affiliate < ActiveRecord::Base
  validates_presence_of :display_name,:name,:search_results_page_title,:staged_search_results_page_title, :locale
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
  has_many :calais_related_searches, :dependent => :destroy
  has_many :popular_urls, :dependent => :destroy
  has_many :featured_collections, :dependent => :destroy
  has_many :indexed_documents, :dependent => :destroy
  has_many :rss_feeds, :dependent => :destroy
  has_many :excluded_urls, :dependent => :destroy
  has_many :sitemaps, :dependent => :destroy
  has_many :top_searches, :dependent => :destroy, :order => 'position ASC', :limit => 5
  validates_associated :popular_urls
  after_destroy :remove_boosted_contents_from_index
  before_validation :set_default_name, :on => :create
  validate :validate_css_property_hash
  before_create :set_uses_one_serp
  before_save :set_default_affiliate_template, :normalize_domains, :ensure_http_prefix, :set_css_properties
  before_validation :set_default_search_results_page_title, :set_default_staged_search_results_page_title, :on => :create
  scope :ordered, {:order => 'display_name ASC'}
  attr_writer :css_property_hash, :staged_css_property_hash
  attr_protected :uses_one_serp

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

  def domains_as_array
    @domains_as_array ||= (self.domains.nil? ? [] : self.domains.split)
  end

  def has_multiple_domains?
    @has_multiple_domains ||= self.domains_as_array.length > 1
  end

  def get_matching_domain(url)
    return unless I18n.locale == :en
    url.blank? ? nil : domains_as_array.detect { |domain| url =~ /#{Regexp.escape(domain)}/i }
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
    %w{ domains header footer affiliate_template_id search_results_page_title favicon_url external_css_url theme css_properties css_property_hash }.each do |field|
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
      :staged_domains => self.staged_domains,
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
      :staged_domains => self.domains,
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

  def normalize_domains(staged = true)
    method = staged ? "staged_domains" : "domains"
    return if self.send(method).nil?
    domain_list = self.send(method).gsub(/(https?:\/\/| )/, '').split.
      select { |domain| domain =~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,3}(\/.*)?$/ix }.
      sort { |a, b| a.length <=> b.length }.uniq
    result = []
    while (domain_list.length > 0)
      result << domain_list.first
      domain_list = domain_list.drop(1).delete_if { |domain| domain.start_with?(domain_list.first) or domain.include?(".#{domain_list.first}") }
    end
    self.send(method + "=", result.join("\n"))
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

  def uncrawled_urls_count
    self.indexed_documents.count(:conditions => ['ISNULL(last_crawled_at)'])
  end

  def crawled_urls_count
    self.indexed_documents.count(:conditions => ['NOT ISNULL(last_crawled_at)'])
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
end
