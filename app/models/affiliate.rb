require 'sass/css'

class Affiliate < ActiveRecord::Base
  include ActiveRecordExtension
  include XmlProcessor
  CLOUD_FILES_CONTAINER = 'affiliate images'
  MAXIMUM_IMAGE_SIZE_IN_KB = 512

  has_and_belongs_to_many :users
  has_many :features, :through => :affiliate_feature_addition
  has_many :boosted_contents, :dependent => :destroy
  has_many :sayt_suggestions, :dependent => :destroy
  has_many :superfresh_urls, :dependent => :destroy
  has_many :featured_collections, :dependent => :destroy
  has_many :indexed_documents, :dependent => :destroy
  has_many :rss_feeds, :order => 'rss_feeds.name ASC, rss_feeds.id ASC', :dependent => :destroy
  has_many :excluded_urls, :dependent => :destroy
  has_many :sitemaps, :dependent => :destroy
  has_many :top_searches, :dependent => :destroy, :order => 'position ASC', :limit => 5
  has_many :site_domains, :dependent => :destroy
  has_many :indexed_domains, :dependent => :destroy
  has_many :affiliate_feature_addition, :dependent => :destroy
  has_many :connections, :order => 'connections.position ASC', :dependent => :destroy
  has_many :connected_connections, :foreign_key => :connected_affiliate_id, :source => :connections, :class_name => 'Connection', :dependent => :destroy
  has_many :document_collections, :order => 'document_collections.name ASC, document_collections.id ASC', :dependent => :destroy
  has_many :url_prefixes, :through => :document_collections
  has_and_belongs_to_many :twitter_profiles
  has_many :flickr_profiles, :dependent => :destroy
  has_many :facebook_profiles, :dependent => :destroy
  has_many :youtube_profiles, :dependent => :destroy
  has_one :image_search_label, :dependent => :destroy
  has_many :navigations, :order => 'navigations.position ASC, navigations.id ASC'
  has_and_belongs_to_many :form_agencies

  has_attached_file :page_background_image,
                    :styles => { :large => "300x150>" },
                    :storage => :cloud_files,
                    :cloudfiles_credentials => "#{Rails.root}/config/rackspace_cloudfiles.yml",
                    :container => CLOUD_FILES_CONTAINER,
                    :path => "#{Rails.env}/:id/page_background_image/:updated_at/:style/:basename.:extension",
                    :ssl => true
  has_attached_file :staged_page_background_image,
                    :styles => { :large => "300x150>" },
                    :storage => :cloud_files,
                    :cloudfiles_credentials => "#{Rails.root}/config/rackspace_cloudfiles.yml",
                    :container => CLOUD_FILES_CONTAINER,
                    :path => "#{Rails.env}/:id/page_background_image/:updated_at/:style/:basename.:extension",
                    :ssl => true
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

  before_validation :set_staged_managed_header_links, :set_staged_managed_footer_links
  before_validation :set_name, :set_default_search_results_page_title, :set_default_staged_search_results_page_title, :on => :create
  validates_presence_of :display_name, :name, :search_results_page_title, :staged_search_results_page_title, :locale
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :within=> (2..33)
  validates_format_of :name, :with=> /^[a-z0-9._-]+$/
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES, :message => 'must be selected'
  validates_attachment_content_type :page_background_image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"
  validates_attachment_content_type :staged_page_background_image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"
  validates_attachment_size :staged_page_background_image, :in => (1..MAXIMUM_IMAGE_SIZE_IN_KB.kilobytes), :message => "must be under #{MAXIMUM_IMAGE_SIZE_IN_KB} KB"
  validates_attachment_content_type :header_image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"
  validates_attachment_content_type :staged_header_image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"
  validates_attachment_size :staged_header_image, :in => (1..MAXIMUM_IMAGE_SIZE_IN_KB.kilobytes), :message => "must be under #{MAXIMUM_IMAGE_SIZE_IN_KB} KB"
  validate :validate_css_property_hash, :validate_header_footer_css, :validate_staged_header_footer, :validate_managed_header_css_properties, :validate_staged_managed_header_links, :validate_staged_managed_footer_links
  validate :external_tracking_code_cannot_be_malformed
  after_validation :update_error_keys
  before_save :set_default_fields, :strip_text_columns, :ensure_http_prefix, :nullify_blank_dublin_core_fields
  before_save :set_css_properties, :sanitize_staged_header_footer, :set_json_fields, :set_search_labels
  before_update :clear_existing_staged_attachments
  after_create :normalize_site_domains
  after_destroy :remove_boosted_contents_from_index

  scope :ordered, {:order => 'display_name ASC'}
  attr_writer :css_property_hash, :staged_css_property_hash
  attr_protected :name, :previous_fields_json, :live_fields_json, :staged_fields_json, :is_validate_staged_header_footer
  attr_accessor :mark_staged_page_background_image_for_deletion, :mark_staged_header_image_for_deletion, :staged_managed_header_links_attributes, :staged_managed_footer_links_attributes, :is_validate_staged_header_footer

  accepts_nested_attributes_for :site_domains, :reject_if => :all_blank
  accepts_nested_attributes_for :sitemaps, :reject_if => :all_blank
  accepts_nested_attributes_for :image_search_label
  accepts_nested_attributes_for :rss_feeds, :reject_if => proc { |a| a[:name].blank? and a[:rss_feed_urls_attributes].present? && a[:rss_feed_urls_attributes]['0'][:url].blank? }
  accepts_nested_attributes_for :document_collections, :reject_if => :all_blank
  accepts_nested_attributes_for :connections, :allow_destroy => true, :reject_if => proc { |a| a[:affiliate_name].blank? and a[:label].blank? }
  accepts_nested_attributes_for :flickr_profiles, :allow_destroy => true
  accepts_nested_attributes_for :facebook_profiles, :allow_destroy => true
  accepts_nested_attributes_for :youtube_profiles, :allow_destroy => true
  accepts_nested_attributes_for :twitter_profiles, :allow_destroy => false
  serialize :dublin_core_mappings, Hash

  USAGOV_AFFILIATE_NAME = 'usagov'
  GOBIERNO_AFFILIATE_NAME = 'gobiernousa'

  DEFAULT_SEARCH_RESULTS_PAGE_TITLE = "{Query} - {SiteName} Search Results"
  BANNED_HTML_ELEMENTS_FROM_HEADER_AND_FOOTER = %w(script style link)

  HUMAN_ATTRIBUTE_NAME_HASH = {
    :display_name => "Site name",
    :name => "Site Handle (visible to searchers in the URL)",
    :staged_search_results_page_title => "Search results page title"
  }

  FONT_FAMILIES = ['Arial, sans-serif', 'Helvetica, sans-serif', '"Trebuchet MS", sans-serif', 'Verdana, sans-serif',
                   'Georgia, serif', 'Times, serif']
  BACKGROUND_REPEAT_VALUES = %w(no-repeat repeat repeat-x repeat-y)

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
      :show_content_box_shadow => '0',
      :page_background_image_repeat => BACKGROUND_REPEAT_VALUES[0] }.merge(THEMES[:default])

  DEFAULT_MANAGED_HEADER_CSS_PROPERTIES = {
      :header_background_color => THEMES[:default][:search_button_background_color],
      :header_text_color => THEMES[:default][:search_button_text_color],
      :header_footer_link_background_color => THEMES[:default][:search_button_text_color],
      :header_footer_link_color => THEMES[:default][:search_button_background_color] }

  NEW_AFFILIATE_CSS_PROPERTIES = { :show_content_border => '0',
                                   :show_content_box_shadow => '1' }

  ATTRIBUTES_WITH_STAGED_AND_LIVE = %w(
      header footer header_footer_css nested_header_footer_css search_results_page_title favicon_url external_css_url uses_managed_header_footer managed_header_css_properties managed_header_home_url managed_header_text managed_header_links managed_footer_links theme css_property_hash)

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
                                            :header_footer_css, :nested_header_footer_css,
                                            :managed_header_css_properties, :managed_header_home_url, :managed_header_text,
                                            :managed_header_links, :managed_footer_links,
                                            :external_tracking_code]
  define_json_columns_accessors :column_name_method => :staged_fields,
                                :fields => [:staged_header, :staged_footer,
                                            :staged_header_footer_css, :staged_nested_header_footer_css,
                                            :staged_managed_header_css_properties, :staged_managed_header_home_url, :staged_managed_header_text,
                                            :staged_managed_header_links, :staged_managed_footer_links]

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
    domains_as_array.detect{ |affiliate_domain| domain =~ /\b#{Regexp.escape(affiliate_domain)}\b/i }.nil? ? false : true
  end

  def update_attributes_for_staging(attributes)
    set_is_validate_staged_header_footer attributes
    if staged_page_background_image_updated_at == page_background_image_updated_at and
        attributes[:staged_page_background_image].present? || attributes[:mark_staged_page_background_image_for_deletion] == '1'
      set_attachment_attributes_to_nil(:staged_page_background_image)
    end
    if staged_header_image_updated_at == header_image_updated_at and
        attributes[:staged_header_image].present? || attributes[:mark_staged_header_image_for_deletion] == '1'
      set_attachment_attributes_to_nil(:staged_header_image)
    end
    attributes[:has_staged_content] = true
    self.update_attributes(attributes)
  end

  def update_attributes_for_live(attributes)
    set_is_validate_staged_header_footer attributes
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
    self.previous_header = header
    self.previous_footer = footer
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
      @css_property_hash ||= (css_properties.blank? ? {} : JSON.parse(css_properties, :symbolize_names => true))
    else
      @css_property_hash ||= css_properties.blank? ? THEMES[self.theme.to_sym] : THEMES[self.theme.to_sym].reverse_merge(JSON.parse(css_properties, :symbolize_names => true))
    end
  end

  def staged_css_property_hash(reload = false)
    @staged_css_property_hash = nil if reload
    if staged_theme.to_sym == :custom
      @staged_css_property_hash ||= (staged_css_properties.blank? ? {} : JSON.parse(staged_css_properties, :symbolize_names => true))
    else
      @staged_css_property_hash ||= staged_css_properties.blank? ? THEMES[self.staged_theme.to_sym] : THEMES[self.staged_theme.to_sym].reverse_merge(JSON.parse(staged_css_properties, :symbolize_names => true))
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
    while domain_list.length > 0
      site_domain = site_domain_hash[domain_list.first]

      added_or_updated_site_domains << site_domain if site_domain.new_record? and site_domain.save

      domain_list = domain_list.drop(1).delete_if do |domain|
        period_prefix = domain_list.first.starts_with?('.') ? '' : '.'
        if  domain.start_with?(domain_list.first) or domain.include?(period_prefix + domain_list.first)
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

    if staged_page_background_image_updated_at != page_background_image_updated_at
      staged_page_background_image.destroy if staged_page_background_image_updated_at?
      copy_attachment_attributes(:page_background_image, :staged_page_background_image)
    end

    if staged_header_image_updated_at != header_image_updated_at
      staged_header_image.destroy if staged_header_image_updated_at?
      copy_attachment_attributes(:header_image, :staged_header_image)
    end
  end

  def set_attributes_from_staged_to_live
    ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |field|
      self.send("#{field}=", self.send("staged_#{field}"))
    end

    if staged_page_background_image_updated_at != page_background_image_updated_at
      page_background_image.destroy if page_background_image_updated_at?
      copy_attachment_attributes(:staged_page_background_image, :page_background_image)
    end

    if staged_header_image_updated_at != header_image_updated_at
      header_image.destroy if header_image_updated_at?
      copy_attachment_attributes(:staged_header_image, :header_image)
    end
  end

  def refresh_indexed_documents(scope)
    indexed_documents.select(:id).send(scope.to_sym).find_in_batches(:batch_size => batch_size(scope)) do |batch|
      Resque.enqueue_with_priority(:low, AffiliateIndexedDocumentFetcher, id, batch.first.id, batch.last.id, scope)
    end
  end

  def sanitized_header
    sanitize_html header
  end

  def sanitized_footer
    sanitize_html footer
  end

  def use_strictui
    self.header = sanitized_header
    self.footer = sanitized_footer
    self.external_css_url = nil
  end

  def unused_features
    features.any? ? Feature.where('id not in (?)',features.collect(&:id)) : Feature.all
  end

  def autodiscover
    if site_domains.size == 1
      autodiscover_sitemap
      autodiscover_rss_feeds
      autodiscover_favicon_url
      autodiscover_social_media
    end
  end

  def autodiscover_sitemap
    begin
      sitemap_url = Robot.find_or_create_by_domain(site_domains.first.domain).sitemap
      Sitemap.create(:url => sitemap_url, :affiliate => self) if sitemap_url
    rescue Exception => e
      Rails.logger.error("Error when autodiscovering sitemap for #{self.name}: #{e.message}")
    end
  end

  def autodiscover_rss_feeds
    begin
      @home_page_doc = @home_page_doc || Nokogiri::HTML(open("http://#{site_domains.first.domain}"))
      @home_page_doc.xpath("//link[@rel='alternate']").each do |link_element|
        rss_feed_url = link_element.attribute("href").value
        title = link_element.attribute("title").nil? ? rss_feed_url : link_element.attribute("title").value
        if rss_feed_url
          rss_feed = self.rss_feeds.new(:name => title)
          rss_feed.rss_feed_urls << RssFeedUrl.new(:url => rss_feed_url)
          rss_feed.save
        end
      end
    rescue Exception => e
      Rails.logger.error("Error when autodiscovering rss feeds for #{self.name}: #{e.message}")
    end
  end

  def autodiscover_favicon_url
    begin
      home_page_url = "http://#{site_domains.first.domain}"
      @home_page_doc = @home_page_doc || Nokogiri::HTML(open(home_page_url))
      icon_url = nil
      @home_page_doc.xpath("//link[@rel='shortcut icon' or @rel='icon']").each do |link_element|
        icon_url = link_element.attribute("href").value
        icon_url = icon_url.start_with?('http://') ? icon_url : "#{home_page_url}#{icon_url}"
        break
      end
      unless icon_url
        icon_url = home_page_url + "/favicon.ico" unless (timeout(10) { open(home_page_url + "/favicon.ico") } rescue nil).nil?
      end
      update_attributes(:favicon_url => icon_url) unless icon_url.nil?
    rescue Exception => e
      Rails.logger.error("Error when autodiscovering favicon for #{self.name}: #{e.message}")
    end
  end

  def autodiscover_social_media
    begin
      @home_page_doc = @home_page_doc || Nokogiri::HTML(open("http://#{site_domains.first.domain}"))
      @home_page_doc.xpath("//a").each do |anchor_tag|
        href = anchor_tag.attribute("href").value rescue nil
        if href
          self.twitter_profiles.create(:screen_name => href.split("/").last) if href =~ /http:\/\/(www\.)?twitter.com\/[A-Za-z0-9]+$/
          self.facebook_profiles.create(:username => href.split("/").last) if href =~ /http:\/\/(www\.)?facebook.com\/[A-Za-z0-9]+$/
          self.flickr_profiles.create(:url => href) if href =~ /http:\/\/(www\.)?flickr.com\/(photos|groups)\/[A-Za-z0-9]+$/
          self.youtube_profiles.create!(:username => href.split("/").last) if href =~ /http:\/\/(www\.)?youtube.com\/[A-Za-z0-9]+$/
        end
      end
    rescue Exception => e
      Rails.logger.error("Error when autodiscovering social media for #{self.name}: #{e.message}")
    end
  end

  def import_flickr_photos
    self.flickr_profiles.each(&:import_photos)
  end

  def excludes_url?(url)
    @excluded_urls_set ||= self.excluded_urls.collect(&:url).to_set
    @excluded_urls_set.include?(url)
  end

  private

  def batch_size(scope)
    (indexed_documents.send(scope.to_sym).size / fetch_concurrency.to_f).ceil
  end

  def remove_boosted_contents_from_index
    boosted_contents.each { |bs| bs.remove_from_index }
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
    self.search_results_page_title = I18n.translate(:default_serp_title, :locale => locale) if self.search_results_page_title.blank?
  end

  def set_default_staged_search_results_page_title
    self.staged_search_results_page_title = I18n.translate(:default_serp_title, :locale => locale) if self.staged_search_results_page_title.blank?
  end

  def ensure_http_prefix
    set_http_prefix :favicon_url, :staged_favicon_url,
                    :external_css_url, :staged_external_css_url,
                    :managed_header_home_url, :staged_managed_header_home_url
  end

  def nullify_blank_dublin_core_fields
    dublin_core_mappings.each_key do |facet_name|
      dublin_core_mappings[facet_name.to_sym] = nil if dublin_core_mappings[facet_name.to_sym].blank?
    end unless dublin_core_mappings.nil?
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

  def set_default_fields
    self.theme = THEMES.keys.first.to_s if theme.blank?
    self.staged_theme = THEMES.keys.first.to_s if staged_theme.blank?
    self.managed_header_text = display_name if managed_header_text.nil?
    self.staged_managed_header_text = display_name if staged_managed_header_text.nil?

    if new_record?
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

  def validate_header_footer_css
    return unless is_validate_staged_header_footer
    begin
      self.staged_nested_header_footer_css = generate_nested_css(staged_header_footer_css)
    rescue Sass::SyntaxError => err
      errors.add(:base, "CSS for the top and bottom of your search results page: #{err}")
    end
  end

  def generate_nested_css(css)
    return if css.blank?
    original_sass_values = Sass::CSS.new(css).render.split("\n")
    sass_values = ".header-footer\n"
    at_rules_to_reject = %w(@charset @import)
    sanitized_sass_values = original_sass_values.reject { |sass_value| sass_value =~ /^(#{at_rules_to_reject.join('|')})/ }.
        collect { |sass_value| "  #{sass_value}" }.
        join("\n")
    sass_values << sanitized_sass_values
    Sass::Engine.new(sass_values, { :style => :compressed }).render
  end

  def validate_staged_header_footer
    return unless is_validate_staged_header_footer
    validate_header_results = validate_html staged_header
    if validate_header_results[:has_malformed_html]
      errors.add(:base, malformed_html_error_message(:top))
    end

    if validate_header_results[:has_banned_elements]
      errors.add(:base, "HTML to customize the top of your search results page can't contain #{BANNED_HTML_ELEMENTS_FROM_HEADER_AND_FOOTER.join(', ')} elements.")
    end

    validate_footer_results = validate_html staged_footer
    if validate_footer_results[:has_malformed_html]
      errors.add(:base, malformed_html_error_message(:bottom))
    end

    if validate_footer_results[:has_banned_elements]
      errors.add(:base, "HTML to customize the bottom of your search results page can't contain #{BANNED_HTML_ELEMENTS_FROM_HEADER_AND_FOOTER.join(', ')} elements.")
    end
  end

  def external_tracking_code_cannot_be_malformed
    validation_results = validate_html external_tracking_code
    if validation_results[:has_malformed_html]
      errors.add(:base, "External tracking code is invalid: #{validation_results[:error_message]}")
    end
  end

  def validate_html(html)
    validate_html_results = {}
    has_banned_elements = false
    unless html.blank?
      html_doc = Nokogiri::HTML::DocumentFragment.parse html
      unless html_doc.errors.empty?
        validate_html_results[:has_malformed_html] = true
        validate_html_results[:error_message] = html_doc.errors.join('. ') + '.' unless html_doc.errors.blank?
      end
      has_banned_elements = true unless html_doc.css(BANNED_HTML_ELEMENTS_FROM_HEADER_AND_FOOTER.join(',')).blank?

    end
    validate_html_results[:has_banned_elements] = has_banned_elements
    validate_html_results
  end

  def malformed_html_error_message(field_name)
    email_link = %Q{<a href="mailto:***REMOVED***">***REMOVED***</a>}
    "HTML to customize the #{field_name.to_s} of your search results is invalid. Click on the validate link below or email us at #{email_link}".html_safe
  end

  def sanitize_html(html)
    unless html.blank?
      doc = Nokogiri::HTML::DocumentFragment.parse html
      doc.css("#{BANNED_HTML_ELEMENTS_FROM_HEADER_AND_FOOTER.join(',')}").each(&:remove)
      doc.to_html
    end
  end

  def existing_site_domain_hash
    Hash[site_domains(true).collect { |current_site_domain| [current_site_domain.domain, current_site_domain] }]
  end

  def update_error_keys
    swap_error_key(:"rss_feeds.base", :base)
    swap_error_key(:"site_domains.domain", :domain)
    swap_error_key(:"connections.connected_affiliate_id", :related_site_handle)
    swap_error_key(:"connections.label", :related_site_label)
    swap_error_key(:staged_page_background_image_file_size, :page_background_image_file_size)
    swap_error_key(:staged_header_image_file_size, :header_image_file_size)
  end

  def previous_fields
    @previous_fields ||= previous_fields_json.blank? ? {} : JSON.parse(previous_fields_json, :symbolize_names => true)
  end

  def live_fields
    @live_fields ||= live_fields_json.blank? ? {} : JSON.parse(live_fields_json, :symbolize_names => true)
  end

  def staged_fields
    @staged_fields ||= staged_fields_json.blank? ? {} : JSON.parse(staged_fields_json, :symbolize_names => true)
  end

  def set_json_fields
    self.previous_fields_json = ActiveSupport::OrderedHash[previous_fields.sort].to_json
    self.live_fields_json = ActiveSupport::OrderedHash[live_fields.sort].to_json
    self.staged_fields_json = ActiveSupport::OrderedHash[staged_fields.sort].to_json
  end

  def clear_existing_staged_attachments
    if staged_page_background_image? and !staged_page_background_image.dirty? and mark_staged_page_background_image_for_deletion == '1'
      staged_page_background_image.clear
    end
    if staged_header_image? and !staged_header_image.dirty? and mark_staged_header_image_for_deletion == '1'
      staged_header_image.clear
    end
  end

  def set_search_labels
    self.default_search_label = I18n.translate(:everything, :locale => locale) if default_search_label.blank?
  end

  def strip_text_columns
    self.ga_web_property_id = ga_web_property_id.strip unless ga_web_property_id.nil?
  end

  def sanitize_staged_header_footer
    self.staged_header = strip_comments(staged_header) unless staged_header.blank?
    self.staged_footer = strip_comments(staged_footer) unless staged_footer.blank?
  end

  def set_attachment_attributes_to_nil(attachment)
    self.send("#{attachment.to_s}_file_name=", nil)
    self.send("#{attachment.to_s}_content_type=", nil)
    self.send("#{attachment.to_s}_file_size=", nil)
    self.send("#{attachment.to_s}_updated_at=", nil)
  end

  def copy_attachment_attributes(from, to)
    self.send("#{to.to_s}_file_name=", self.send("#{from}_file_name"))
    self.send("#{to.to_s}_content_type=", self.send("#{from}_content_type"))
    self.send("#{to.to_s}_file_size=", self.send("#{from}_file_size"))
    self.send("#{to.to_s}_updated_at=", self.send("#{from}_updated_at"))
  end

  def set_is_validate_staged_header_footer(attributes)
    self.is_validate_staged_header_footer = attributes[:staged_uses_managed_header_footer] == '0'
  end
end
