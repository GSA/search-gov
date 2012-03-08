require 'sass/css'

class Affiliate < ActiveRecord::Base
  CLOUD_FILES_CONTAINER = 'affiliate images'
  MAXIMUM_IMAGE_SIZE_IN_KB = 512

  validates_presence_of :display_name, :name, :search_results_page_title, :staged_search_results_page_title, :locale, :results_source
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
  has_many :indexed_domains, :dependent => :destroy
  has_attached_file :header_image,
                    :styles => { :large => "300x150>" },
                    :storage => :cloud_files,
                    :cloudfiles_credentials => "#{Rails.root}/config/rackspace_cloudfiles.yml",
                    :container => CLOUD_FILES_CONTAINER,
                    :path => "#{Rails.env}/:id/managed_header_image/:updated_at/:style/:basename.:extension",
                    :ssl => true
  has_attached_file :staged_header_image,
                    :styles => { :large => "300x150>" },
                    :storage => :cloud_files,
                    :cloudfiles_credentials => "#{Rails.root}/config/rackspace_cloudfiles.yml",
                    :container => CLOUD_FILES_CONTAINER,
                    :path => "#{Rails.env}/:id/managed_header_image/:updated_at/:style/:basename.:extension",
                    :ssl => true

  has_many :document_collections, :dependent => :destroy
  validates_associated :popular_urls
  after_destroy :remove_boosted_contents_from_index
  validate :validate_css_property_hash, :validate_header_footer_css, :validate_managed_header_css_properties, :validate_staged_managed_header_links, :validate_staged_managed_footer_links
  validates_attachment_content_type :header_image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"
  validates_attachment_content_type :staged_header_image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"
  validates_attachment_size :staged_header_image, :in => (1..MAXIMUM_IMAGE_SIZE_IN_KB.kilobytes), :message => "must be under #{MAXIMUM_IMAGE_SIZE_IN_KB} KB"
  before_save :set_default_one_serp_fields, :set_default_affiliate_template, :ensure_http_prefix, :set_css_properties, :set_header_footer_sass, :set_json_fields
  before_update :clear_existing_staged_header_image
  before_validation :set_staged_managed_header_links, :set_staged_managed_footer_links
  before_validation :set_name, :set_default_search_results_page_title, :set_default_staged_search_results_page_title, :on => :create
  after_validation :update_error_keys
  after_create :normalize_site_domains
  scope :ordered, {:order => 'display_name ASC'}
  attr_writer :css_property_hash, :staged_css_property_hash
  attr_protected :uses_one_serp, :previous_fields_json, :live_fields_json, :staged_fields_json
  attr_accessor :mark_staged_header_image_for_deletion, :staged_managed_header_links_attributes, :staged_managed_footer_links_attributes

  accepts_nested_attributes_for :site_domains, :reject_if => :all_blank
  accepts_nested_attributes_for :sitemaps, :reject_if => :all_blank
  accepts_nested_attributes_for :rss_feeds, :reject_if => :all_blank

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
                       :page_background_color => '#F7F7F7',
                       :content_background_color => '#FFFFFF',
                       :content_border_color => '#CACACA',
                       :content_box_shadow_color => '#555555',
                       :search_button_text_color => '#FFFFFF',
                       :search_button_background_color => '#00396F',
                       :left_tab_text_color => '#9E3030',
                       :title_link_color => '#2200CC',
                       :visited_title_link_color => '#800080',
                       :description_text_color => '#000000',
                       :url_link_color => '#008000' }
  THEMES[:elegant] = { :display_name => 'Gettysburg',
                       :page_background_color => '#F7F7F7',
                       :content_background_color => '#FFFFFF',
                       :content_border_color => '#CACACA',
                       :content_box_shadow_color => '#555555',
                       :search_button_text_color => '#FFFFFF',
                       :search_button_background_color => '#336699',
                       :left_tab_text_color => '#C71D2E',
                       :title_link_color => '#336699',
                       :visited_title_link_color => '#8F5576',
                       :description_text_color => '#595959',
                       :url_link_color => '#007F00' }
  THEMES[:fun_blue] = { :display_name => 'Virgin Islands',
                        :page_background_color => '#F7F7F7',
                        :content_background_color => '#FFFFFF',
                        :content_border_color => '#CACACA',
                        :content_box_shadow_color => '#555555',
                        :search_button_text_color => '#FFFFFF',
                        :search_button_background_color => '#0CA5D8',
                        :left_tab_text_color => '#87CB00',
                        :title_link_color => '#0CA5D8',
                       :visited_title_link_color => '#A972AB',
                       :description_text_color => '#444444',
                       :url_link_color => '#3DB7E0' }
  THEMES[:gray] = { :display_name => 'Mount Rushmore',
                    :page_background_color => '#F7F7F7',
                    :content_background_color => '#FFFFFF',
                    :content_border_color => '#CACACA',
                    :content_box_shadow_color => '#555555',
                    :search_button_text_color => '#FFFFFF',
                    :search_button_background_color => '#555555',
                    :left_tab_text_color => '#A10000',
                    :title_link_color => '#555555',
                    :visited_title_link_color => '#854268',
                    :description_text_color => '#595959',
                    :url_link_color => '#2C5D80' }
  THEMES[:natural] = { :display_name => 'Grand Canyon',
                       :page_background_color => '#F7F7F7',
                       :content_background_color => '#FFFFFF',
                       :content_border_color => '#CACACA',
                       :content_box_shadow_color => '#555555',
                       :search_button_text_color => '#FFFFFF',
                       :search_button_background_color => '#B58100',
                       :left_tab_text_color => '#B58100',
                       :title_link_color => '#B58100',
                       :visited_title_link_color => '#008EB5',
                       :description_text_color => '#333333',
                       :url_link_color => '#B58100' }
  THEMES[:custom] = { :display_name => 'Custom' }

  DEFAULT_CSS_PROPERTIES = {
      :font_family => FONT_FAMILIES[0],
      :show_content_border => '0',
      :show_content_box_shadow => '0' }.merge(THEMES[:default])

  DEFAULT_MANAGED_HEADER_CSS_PROPERTIES = {
      :header_background_color => THEMES[:default][:search_button_background_color],
      :header_text_color => THEMES[:default][:search_button_text_color],
      :header_footer_link_background_color => THEMES[:default][:search_button_text_color],
      :header_footer_link_color => THEMES[:default][:search_button_background_color] }

  NEW_AFFILIATE_CSS_PROPERTIES = { :show_content_border => '0',
                                   :show_content_box_shadow => '1' }
  RESULTS_SOURCES = %w(bing odie bing+odie)
  ATTRIBUTES_WITH_STAGED_AND_LIVE = %w(
      header footer header_footer_css affiliate_template_id search_results_page_title favicon_url external_css_url uses_one_serp uses_managed_header_footer managed_header_css_properties managed_header_home_url managed_header_text managed_header_links managed_footer_links theme css_property_hash)

  def self.define_json_columns_accessors(args)
    column_name_method = args[:column_name_method]
    fields = args[:fields]

    fields.each do |field|
      define_method field do
        self.send(column_name_method).send("[]", field)
      end

      define_method :"#{field}=" do |arg|
        self.send(column_name_method).send("[]=", field, arg)
      end
    end
  end

  define_json_columns_accessors :column_name_method => :previous_fields, :fields => [:previous_header, :previous_footer]
  define_json_columns_accessors :column_name_method => :live_fields,
                                :fields => [:header, :footer,
                                            :header_footer_sass, :header_footer_css,
                                            :managed_header_css_properties, :managed_header_home_url, :managed_header_text,
                                            :managed_header_links, :managed_footer_links]
  define_json_columns_accessors :column_name_method => :staged_fields,
                                :fields => [:staged_header, :staged_footer,
                                            :staged_header_footer_sass, :staged_header_footer_css,
                                            :staged_managed_header_css_properties, :staged_managed_header_home_url, :staged_managed_header_text,
                                            :staged_managed_header_links, :staged_managed_footer_links]

  def name=(name)
    new_record? ? (write_attribute(:name, name)) : (raise "This field cannot be changed.")
  end

  def domains_as_array(reload = false)
    @domains_as_array ||= site_domains(reload).ordered.collect { |site_domain| site_domain.domain }
  end

  def scope_ids_as_array
    @scope_ids_as_array ||= (self.scope_ids.nil? ? [] : self.scope_ids.split(',').each{|scope| scope.strip!})
  end

  def scope_keywords_as_array
    @scope_keywords_as_array ||= (self.scope_keywords.nil? ? [] : self.scope_keywords.split(',').each{|keyword| keyword.strip!})
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
    if staged_header_image_updated_at == header_image_updated_at and
        attributes[:staged_header_image].present? || attributes[:mark_staged_header_image_for_deletion] == '1'
      self.staged_header_image_file_name = nil
      self.staged_header_image_content_type = nil
      self.staged_header_image_file_size = nil
      self.staged_header_image_updated_at = nil
    end
    attributes[:has_staged_content] = true
    self.update_attributes(attributes)
  end

  def update_attributes_for_live(attributes)
    transaction do
      if self.update_attributes(attributes)
        self.previous_header = header
        self.previous_footer = footer
        set_attributes_from_staged_to_live
        self.has_staged_content = false
        self.save!
        true
      else
        false
      end
    end
  end

  def build_search_results_page_title(query)
    build_page_title(self.search_results_page_title, query)
  end

  def build_staged_search_results_page_title(query)
    build_page_title(self.staged_search_results_page_title, query)
  end

  def build_page_title(page_title, query)
    query_string = query.blank? ? '' : query
    page_title = page_title.gsub(/\{query\}/i, query_string)
    page_title.gsub(/\{sitename\}/i, self.display_name)
  end

  def push_staged_changes
    set_attributes_from_staged_to_live
    self.has_staged_content = false
    save!
  end

  def cancel_staged_changes
    set_attributes_from_live_to_staged
    self.has_staged_content = false
    save!
  end

  def sync_staged_attributes
    self.cancel_staged_changes unless self.has_staged_content?
  end

  def active_rss_feeds
    rss_feeds.where(:is_active => true)
  end

  def has_active_rss_feeds?
    active_rss_feeds.present?
  end

  def active_document_collections
    document_collections.joins(:url_prefixes).select("distinct document_collections.*")
  end

  def has_active_document_collections?
    active_document_collections.present?
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

  def css_property_hash(reload = false)
    @css_property_hash = nil if reload
    if theme.to_sym == :custom
      @css_property_hash ||= (css_properties.blank? ? {} : JSON.parse(css_properties, :symbolize_keys => true))
    else
      @css_property_hash ||= css_properties.blank? ? THEMES[self.theme.to_sym] : THEMES[self.theme.to_sym].reverse_merge(JSON.parse(css_properties, :symbolize_keys => true))
    end
  end

  def staged_css_property_hash(reload = false)
    @staged_css_property_hash = nil if reload
    if staged_theme.to_sym == :custom
      @staged_css_property_hash ||= (staged_css_properties.blank? ? {} : JSON.parse(staged_css_properties, :symbolize_keys => true))
    else
      @staged_css_property_hash ||= staged_css_properties.blank? ? THEMES[self.staged_theme.to_sym] : THEMES[self.staged_theme.to_sym].reverse_merge(JSON.parse(staged_css_properties, :symbolize_keys => true))
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

  def uses_odie_results?
    self.results_source == 'odie'
  end

  def uses_bing_results?
    self.results_source == 'bing'
  end

  def uses_bing_odie_results?
    self.results_source == 'bing+odie'
  end

  def show_content_border?
    css_property_hash[:show_content_border] == '1'
  end

  def show_content_box_shadow?
    css_property_hash[:show_content_box_shadow] == '1'
  end

  def set_attributes_from_live_to_staged
    ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |field|
      self.send("staged_#{field}=", self.send("#{field}"))
    end

    if staged_header_image_updated_at != header_image_updated_at
      staged_header_image.destroy if staged_header_image_updated_at?
      self.staged_header_image_file_name = header_image_file_name
      self.staged_header_image_content_type = header_image_content_type
      self.staged_header_image_file_size = header_image_file_size
      self.staged_header_image_updated_at = header_image_updated_at
    end
  end

  def set_attributes_from_staged_to_live
    ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |field|
      self.send("#{field}=", self.send("staged_#{field}"))
    end

    if staged_header_image_updated_at != header_image_updated_at
      header_image.destroy if header_image_updated_at?
      self.header_image_file_name = staged_header_image_file_name
      self.header_image_content_type = staged_header_image_content_type
      self.header_image_file_size = staged_header_image_file_size
      self.header_image_updated_at = staged_header_image_updated_at
    end
  end

  def check_domains_for_live_code
    live_domains_list = []
    domains = self.site_domains.collect{|site_domain| site_domain.domain }
    domains << (JSON.parse(self.live_fields_json)["managed_header_text"] rescue nil) if self.live_fields_json
    domains.compact.each do |domain|
      domain_url = (domain =~ /^http:\/\/.*|^https:\/\/.*/).nil? ? "http://#{domain}" : domain
      URI.parse(domain_url) rescue next
      begin
        doc = Nokogiri::HTML(Kernel.open(domain_url)) rescue nil
        live_domains_list << domain if doc and doc.xpath("//form[@action='http://search.usa.gov/search']").any?
      rescue Exception => e
      end
    end
    live_domains_list.join(';')
  end

  def refresh_indexed_documents
    indexed_documents.select(:id).find_in_batches(:batch_size => batch_size) do |batch|
      Resque.enqueue_with_priority(:low, AffiliateIndexedDocumentFetcher, id, batch.first.id, batch.last.id)
    end
  end

  private

  def batch_size
    (indexed_documents.size / fetch_concurrency.to_f).ceil
  end

  def remove_boosted_contents_from_index
    boosted_contents.each { |bs| bs.remove_from_index }
  end

  def set_default_affiliate_template
    self.staged_affiliate_template_id = AffiliateTemplate.default_id if staged_affiliate_template_id.blank?
    self.affiliate_template_id = AffiliateTemplate.default_id if affiliate_template_id.blank?
  end

  def set_name
    if self.name.blank?
      self.name = self.display_name.downcase.gsub(/[^a-z0-9._-]/, '')[0, 33] unless self.display_name.blank?
      self.name = nil if !self.name.blank? and self.name.length < 3
      self.name = nil if !self.name.blank? and Affiliate.find_by_name(self.name)
      self.name = Digest::MD5.hexdigest("#{Time.now.to_s}")[0..8] if self.name.blank?
    else
      self.name = self.name.downcase
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
    self.managed_header_home_url = "http://#{managed_header_home_url}" unless managed_header_home_url.blank? or managed_header_home_url =~ %r{^http(s?)://}i
    self.staged_managed_header_home_url = "http://#{staged_managed_header_home_url}" unless staged_managed_header_home_url.blank? or staged_managed_header_home_url =~ %r{^http(s?)://}i
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
        validate_color_property(key, hash[key])
      end
    end
  end

  def validate_managed_header_css_properties
    validates_color_in_managed_header_css_properties staged_managed_header_css_properties unless staged_managed_header_css_properties.blank?
    validates_color_in_managed_header_css_properties managed_header_css_properties unless managed_header_css_properties.blank?
  end

  def validates_color_in_managed_header_css_properties(css_properties)
    DEFAULT_MANAGED_HEADER_CSS_PROPERTIES.keys.each do |key|
      validate_color_property(key, css_properties[key])
    end
  end

  def validate_color_property(key, value)
    return unless key.to_s =~ /color$/ and value.present?
    errors.add(:base, "#{key.to_s.humanize} should consist of a # character followed by 3 or 6 hexadecimal digits") unless value =~ /^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$/
  end

  def set_staged_managed_header_links
    return if @staged_managed_header_links_attributes.nil?
    self.staged_managed_header_links = []
    set_managed_links(@staged_managed_header_links_attributes, staged_managed_header_links)
  end

  def set_staged_managed_footer_links
    return if @staged_managed_footer_links_attributes.nil?
    self.staged_managed_footer_links = []
    set_managed_links(@staged_managed_footer_links_attributes, staged_managed_footer_links)
  end

  def set_managed_links(managed_links_attributes, managed_links)
     managed_links_attributes.values.sort_by { |link| link[:position].to_i }.each do |link|
      next if link[:title].blank? and link[:url].blank?
      url = link[:url]
      url = "http://#{url}" if url.present? and url !~ %r{^http(s?)://}i
      managed_links << { :position => link[:position].to_i, :title => link[:title], :url => url }
    end
  end

  def validate_staged_managed_header_links
    validate_managed_links(staged_managed_header_links, :header)
  end

  def validate_staged_managed_footer_links
    validate_managed_links(staged_managed_footer_links, :footer)
  end

  def validate_managed_links(links, link_type)
    return if links.blank?
    add_blank_link_title_error = false
    add_blank_link_url_error = false
    links.each do |link|
      add_blank_link_title_error = true if link[:title].blank? and link[:url].present?
      add_blank_link_url_error = true if link[:title].present? and link[:url].blank?
    end
    errors.add(:base, "#{link_type.to_s.humanize} link title can't be blank") if add_blank_link_title_error
    errors.add(:base, "#{link_type.to_s.humanize} link URL can't be blank") if add_blank_link_url_error
  end

  def set_default_one_serp_fields
    self.uses_one_serp = true if new_record? and uses_one_serp.nil?
    self.staged_uses_one_serp = uses_one_serp if staged_uses_one_serp.nil?

    self.theme = THEMES.keys.first.to_s if theme.blank?
    self.staged_theme = THEMES.keys.first.to_s if staged_theme.blank?
    self.managed_header_text = display_name if managed_header_text.nil?
    self.staged_managed_header_text = display_name if staged_managed_header_text.nil?

    if new_record? and uses_one_serp?
      self.uses_managed_header_footer = true if uses_managed_header_footer.nil?
      self.staged_uses_managed_header_footer = true if staged_uses_managed_header_footer.nil?
      @css_property_hash = ActiveSupport::OrderedHash.new if @css_property_hash.nil?
      @css_property_hash.reverse_merge!(NEW_AFFILIATE_CSS_PROPERTIES)
      @staged_css_property_hash = ActiveSupport::OrderedHash.new if @staged_css_property_hash.nil?
      @staged_css_property_hash.reverse_merge!(NEW_AFFILIATE_CSS_PROPERTIES)
    end

    if uses_managed_header_footer?
      self.managed_header_css_properties = ActiveSupport::OrderedHash.new if managed_header_css_properties.nil?
      current_css_property_hash = theme.to_sym == :custom ? css_property_hash : THEMES[theme.to_sym]
      self.managed_header_css_properties[:header_background_color] = current_css_property_hash[:search_button_background_color] if managed_header_css_properties[:header_background_color].nil?
      self.managed_header_css_properties[:header_text_color] = current_css_property_hash[:search_button_text_color] if managed_header_css_properties[:header_text_color].nil?
      self.managed_header_css_properties[:header_footer_link_color] = current_css_property_hash[:search_button_background_color] if managed_header_css_properties[:header_footer_link_color].blank?
      self.managed_header_css_properties[:header_footer_link_background_color] = current_css_property_hash[:search_button_text_color] if managed_header_css_properties[:header_footer_link_background_color].blank?
    end

    if staged_uses_managed_header_footer?
      self.staged_managed_header_css_properties = ActiveSupport::OrderedHash.new if staged_managed_header_css_properties.nil?
      current_staged_css_property_hash = staged_theme.to_sym == :custom ? staged_css_property_hash : THEMES[staged_theme.to_sym]
      self.staged_managed_header_css_properties[:header_background_color] = current_staged_css_property_hash[:search_button_background_color] if staged_managed_header_css_properties[:header_background_color].nil?
      self.staged_managed_header_css_properties[:header_text_color] = current_staged_css_property_hash[:search_button_text_color] if staged_managed_header_css_properties[:header_text_color].nil?
      self.staged_managed_header_css_properties[:header_footer_link_color] = current_staged_css_property_hash[:search_button_background_color] if staged_managed_header_css_properties[:header_footer_link_color].blank?
      self.staged_managed_header_css_properties[:header_footer_link_background_color] = current_staged_css_property_hash[:search_button_text_color] if staged_managed_header_css_properties[:header_footer_link_background_color].blank?
    end
  end

  def set_css_properties
    self.css_properties = @css_property_hash.to_json unless @css_property_hash.blank?
    self.staged_css_properties = @staged_css_property_hash.to_json unless @staged_css_property_hash.blank?
  end

  def set_header_footer_sass
    self.staged_header_footer_sass = staged_header_footer_css.blank? ? nil : parse_css(staged_header_footer_css)
    self.header_footer_sass = header_footer_css.blank? ? nil : parse_css(header_footer_css)
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
    sass_values = Sass::CSS.new(css).render
    Sass::Engine.new(sass_values).render
    sass_values.split("\n").collect { |sass_value| "  #{sass_value}" }.join("\n")
  end

  def existing_site_domain_hash
    Hash[site_domains(true).collect { |current_site_domain| [current_site_domain.domain, current_site_domain] }]
  end

  def update_error_keys
    if self.errors.include?(:"site_domains.domain")
      error_value = self.errors.delete(:"site_domains.domain")
      self.errors.add(:domain, error_value)
    end
    if errors.include?(:staged_header_image_file_size)
      errors.add(:header_image_file_size, errors.delete(:staged_header_image_file_size))
    end
  end

  def previous_fields
    @previous_fields ||= previous_fields_json.blank? ? {} : JSON.parse(previous_fields_json, :symbolize_keys => true)
  end

  def live_fields
    @live_fields ||= live_fields_json.blank? ? {} : JSON.parse(live_fields_json, :symbolize_keys => true)
  end

  def staged_fields
    @staged_fields ||= staged_fields_json.blank? ? {} : JSON.parse(staged_fields_json, :symbolize_keys => true)
  end

  def set_json_fields
    self.previous_fields_json = ActiveSupport::OrderedHash[previous_fields.sort].to_json
    self.live_fields_json = ActiveSupport::OrderedHash[live_fields.sort].to_json
    self.staged_fields_json = ActiveSupport::OrderedHash[staged_fields.sort].to_json
  end

  def clear_existing_staged_header_image
    if staged_header_image? and !staged_header_image.dirty? and mark_staged_header_image_for_deletion == '1'
      staged_header_image.clear
    end
  end
end
