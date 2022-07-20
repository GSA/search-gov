# frozen_string_literal: true

require 'digest'
require 'sass/css'

class Affiliate < ApplicationRecord
  extend HumanAttributeName
  extend HashColumnsAccessible
  include Dupable
  include LogstashPrefix

  MAXIMUM_IMAGE_SIZE_IN_KB = 512
  MAXIMUM_MOBILE_IMAGE_SIZE_IN_KB = 64
  MAXIMUM_HEADER_TAGLINE_LOGO_IMAGE_SIZE_IN_KB = 16
  VALID_IMAGE_CONTENT_TYPES = %w[image/gif image/jpeg image/pjpeg image/png image/x-png].freeze
  INVALID_CONTENT_TYPE_MESSAGE = 'must be GIF, JPG, or PNG'
  INVALID_IMAGE_SIZE_MESSAGE = "must be under #{MAXIMUM_IMAGE_SIZE_IN_KB} KB"
  INVALID_MOBILE_IMAGE_SIZE_MESSAGE = "must be under #{MAXIMUM_MOBILE_IMAGE_SIZE_IN_KB} KB"
  INVALID_HEADER_TAGLINE_LOGO_IMAGE_SIZE_MESSAGE = "must be under #{MAXIMUM_HEADER_TAGLINE_LOGO_IMAGE_SIZE_IN_KB} KB"
  MAX_NAME_LENGTH = 33

  with_options dependent: :destroy do |assoc|
    assoc.has_many :affiliate_feature_addition
    assoc.has_many :affiliate_twitter_settings
    assoc.has_many :boosted_contents
    assoc.has_many :connections, -> { order 'connections.position ASC' },
                   inverse_of: :affiliate
    assoc.has_many :connected_connections,
                   foreign_key: :connected_affiliate_id,
                   class_name: 'Connection',
                   inverse_of: :connected_affiliate
    assoc.has_many :document_collections,
                   -> { order 'document_collections.name ASC, document_collections.id ASC' },
                   inverse_of: :affiliate

    assoc.has_many :excluded_domains, -> { order 'domain ASC' },
                   inverse_of: :affiliate
    assoc.has_many :excluded_urls
    assoc.has_many :featured_collections
    assoc.has_many(:features, through: :affiliate_feature_addition)
    assoc.has_many :flickr_profiles, -> { order 'flickr_profiles.url ASC' },
                   inverse_of: :affiliate
    assoc.has_many :i14y_memberships
    assoc.has_one :image_search_label
    assoc.has_many :indexed_documents
    assoc.has_many :memberships
    assoc.has_many :navigations,
                   -> { order 'navigations.position ASC, navigations.id ASC' },
                   inverse_of: :affiliate
    assoc.has_many :routed_queries
    assoc.has_many :rss_feeds,
                   as: :owner,
                   inverse_of: :owner
    assoc.has_many :sayt_suggestions
    assoc.has_many :site_domains, -> { order 'domain ASC' }, inverse_of: :affiliate
    assoc.has_one :site_feed_url
    assoc.has_many :superfresh_urls
    assoc.has_one :alert
    assoc.has_many :watchers, -> { order 'name ASC' }, inverse_of: :affiliate
    assoc.has_many :tag_filters, -> { order 'tag ASC' }, inverse_of: :affiliate
  end

  has_many :users, -> { order 'first_name' }, through: :memberships

  has_many :default_users,
           class_name: 'User',
           foreign_key: 'default_affiliate_id',
           dependent: :nullify,
           inverse_of: :default_affiliate

  has_many :rss_feed_urls, -> { distinct }, through: :rss_feeds
  has_many :url_prefixes, through: :document_collections
  has_many :twitter_profiles, -> { order 'twitter_profiles.screen_name ASC' }, through: :affiliate_twitter_settings
  has_and_belongs_to_many :instagram_profiles, -> { order 'instagram_profiles.username ASC' }
  has_and_belongs_to_many :youtube_profiles, -> { order 'youtube_profiles.title ASC' }
  has_many :i14y_drawers, -> { order 'handle' }, through: :i14y_memberships
  has_many :routed_query_keywords, -> { order 'keyword' }, through: :routed_queries
  belongs_to :agency
  belongs_to :language, foreign_key: :locale, primary_key: :code, inverse_of: :affiliates

  AWS_IMAGE_SETTINGS = {
    styles: { large: '300x150>' },
    storage: :s3,
    s3_credentials: Rails.application.secrets.aws_image_bucket,
    url: ':s3_alias_url',
    s3_host_alias: Rails.application.secrets.aws_image_bucket[:s3_host_alias],
    s3_protocol: 'https',
    s3_region: Rails.application.secrets.aws_image_bucket[:s3_region]
  }.freeze

  # The "mobile_" and "managed_" prefixes in "mobile_logo", "managed_header", etc.,
  # are remnants from the days of the "legacy" SERP. We have left the prefixes as-is
  # to avoid extensive renaming. So when you see "mobile_whatever", or "managed_whatever",
  # just think "whatever".
  has_attached_file :mobile_logo,
                    AWS_IMAGE_SETTINGS.merge(path: "#{Rails.env}/site/:id/mobile_logo/:updated_at/:style/:filename")
  has_attached_file :header_tagline_logo,
                    AWS_IMAGE_SETTINGS.merge(path: "#{Rails.env}/site/:id/header_tagline_logo/:updated_at/:style/:filename")

  before_validation :set_default_fields, on: :create
  before_validation :downcase_name
  before_validation :set_managed_header_links, :set_managed_footer_links
  before_validation :set_managed_no_results_pages_alt_links
  before_validation :set_default_labels
  before_validation :strip_bing_v5_key

  before_validation do |record|
    AttributeProcessor.squish_attributes(record,
                                         :ga_web_property_id,
                                         :header_tagline_font_size,
                                         :logo_alt_text,
                                         :navigation_dropdown_label,
                                         :related_sites_dropdown_label,
                                         assign_nil_on_blank: true)
    AttributeProcessor.prepend_attributes_with_http(record,
                                                    :favicon_url,
                                                    :website)
  end

  before_validation :set_api_access_key, unless: :api_access_key?
  validates_presence_of :display_name, :name, :locale, :theme
  validates_uniqueness_of :api_access_key, :name, case_sensitive: false
  validates_length_of :name, within: (2..MAX_NAME_LENGTH)
  validates_format_of :name, with: /\A[a-z0-9._-]+\z/
  validates_format_of :bing_v5_key, with: /\A[0-9a-f]{32}\z/i, allow_nil: true
  validates_inclusion_of :search_engine, in: SEARCH_ENGINES
  validates_url :header_tagline_url, allow_blank: true

  validates_attachment_content_type :mobile_logo,
                                    content_type: VALID_IMAGE_CONTENT_TYPES,
                                    message: INVALID_CONTENT_TYPE_MESSAGE
  validates_attachment_size :mobile_logo,
                            in: (1..MAXIMUM_MOBILE_IMAGE_SIZE_IN_KB.kilobytes),
                            message: INVALID_MOBILE_IMAGE_SIZE_MESSAGE

  validates_attachment_content_type :header_tagline_logo,
                                    content_type: VALID_IMAGE_CONTENT_TYPES,
                                    message: INVALID_CONTENT_TYPE_MESSAGE
  validates_attachment_size :header_tagline_logo,
                            in: (1..MAXIMUM_HEADER_TAGLINE_LOGO_IMAGE_SIZE_IN_KB.kilobytes),
                            message: INVALID_HEADER_TAGLINE_LOGO_IMAGE_SIZE_MESSAGE

  validate :html_columns_cannot_be_malformed,
           :validate_css_property_hash,
           :validate_managed_footer_links,
           :validate_managed_header_links,
           :validate_managed_no_results_pages_alt_links,
           :language_valid,
           :validate_managed_no_results_pages_guidance_text

  after_validation :update_error_keys
  before_save :set_css_properties, :generate_look_and_feel_css, :set_json_fields, :set_search_labels
  before_update :clear_existing_attachments
  after_commit :normalize_site_domains,             on: :create
  after_commit :remove_boosted_contents_from_index, on: :destroy

  scope :ordered, -> { order('display_name ASC') }
  scope :active, -> { where(active: true) }

  attr_writer :css_property_hash
  attr_accessor :mark_mobile_logo_for_deletion,
                :mark_header_tagline_logo_for_deletion,
                :managed_header_links_attributes,
                :managed_footer_links_attributes,
                :managed_no_results_pages_alt_links_attributes

  accepts_nested_attributes_for :site_domains, reject_if: :all_blank
  accepts_nested_attributes_for :image_search_label
  accepts_nested_attributes_for :rss_feeds
  accepts_nested_attributes_for :document_collections, reject_if: :all_blank
  accepts_nested_attributes_for :connections, allow_destroy: true, reject_if: proc { |a| a[:affiliate_name].blank? and a[:label].blank? }
  accepts_nested_attributes_for :flickr_profiles, allow_destroy: true
  accepts_nested_attributes_for :twitter_profiles, allow_destroy: false

  USAGOV_AFFILIATE_NAME = 'usagov'
  GOBIERNO_AFFILIATE_NAME = 'gobiernousa'

  DEFAULT_SEARCH_RESULTS_PAGE_TITLE = '{Query} - {SiteName} Search Results'
  BANNED_HTML_ELEMENTS_FROM_HEADER_AND_FOOTER = %w[form script style link].freeze

  THEMES = ActiveSupport::OrderedHash.new
  THEMES[:default] = {
    content_background_color: '#FFFFFF',
    description_text_color: '#000000',
    footer_background_color: '#DFDFDF',
    footer_links_text_color: '#000000',
    header_links_background_color: '#0068c4',
    header_links_text_color: '#fff',
    header_text_color: '#000000',
    header_background_color: '#FFFFFF',
    header_tagline_background_color: '#000000',
    header_tagline_color: '#FFFFFF',
    search_button_text_color: '#FFFFFF',
    search_button_background_color: '#00396F',
    left_tab_text_color: '#9E3030',
    navigation_background_color: '#F1F1F1',
    navigation_link_color: '#505050',
    page_background_color: '#DFDFDF',
    title_link_color: '#2200CC',
    url_link_color: '#006800',
    visited_title_link_color: '#800080'
  }

  THEMES[:custom] = { display_name: 'Custom' }

  DEFAULT_CSS_PROPERTIES = {
    font_family: FontFamily::DEFAULT,
    header_tagline_font_family: HeaderTaglineFontFamily::DEFAULT,
    header_tagline_font_size: '1.3em',
    header_tagline_font_style: 'italic',
    logo_alignment: LogoAlignment::DEFAULT
  }.merge(THEMES[:default])

  CUSTOM_INDEXING_LANGUAGES = %w[en es].freeze

  COMMON_INDEXING_LANGUAGE = 'babel'

  def indexing_locale
    CUSTOM_INDEXING_LANGUAGES.include?(locale) ? locale : COMMON_INDEXING_LANGUAGE
  end

  define_hash_columns_accessors column_name_method: :live_fields,
                                fields: %i[managed_header_links
                                           managed_footer_links
                                           external_tracking_code
                                           submitted_external_tracking_code
                                           mobile_look_and_feel_css
                                           logo_alt_text
                                           header_tagline
                                           header_tagline_url
                                           page_one_more_results_pointer
                                           no_results_pointer
                                           footer_fragment
                                           navigation_dropdown_label
                                           related_sites_dropdown_label
                                           additional_guidance_text
                                           managed_no_results_pages_alt_links]

  define_hash_columns_accessors column_name_method: :css_property_hash,
                                fields: %i[header_tagline_font_family
                                           header_tagline_font_size
                                           header_tagline_font_style]

  model_name.class_eval do
    def singular_route_key
      'site'
    end
  end

  def self.do_not_dup_attributes
    @@do_not_dup_attributes ||= begin
      logo_attrs = column_names.select do |column_name|
        column_name =~ /\A(header_tagline_logo|mobile_logo)/
      end
      %w[api_access_key name].push(*logo_attrs).freeze
    end
  end

  def self.human_attribute_name_hash
    @@human_attribute_name_hash ||= {
      display_name: 'Display name',
      name: 'Site Handle (visible to searchers in the URL)',
      mobile_logo_file_size: 'Logo file size',
      mobile_header_tagline_logo_file_size: 'Header Tagline Logo file size'
    }
  end

  def scope_ids_as_array
    @scope_ids_as_array ||= (scope_ids.nil? ? [] : scope_ids.split(',').each(&:strip!))
  end

  def has_multiple_domains?
    site_domains.count > 1
  end

  def recent_user_activity
    users.collect(&:last_request_at).compact.max
  end

  def css_property_hash(reload = false)
    @css_property_hash = nil if reload
    if theme.to_sym == :default
      @css_property_hash ||= THEMES[:default].reverse_merge(load_css_properties)
    else
      @css_property_hash ||= load_css_properties
    end
  end

  def add_site_domains(site_domain_param_hash)
    transaction do
      added_site_domains = site_domain_param_hash.map do |domain, site_name|
        site_domain = site_domains.build(domain: domain, site_name: site_name)
        site_domain if site_domain.save
      end.compact
      normalize_site_domains
      site_domains.where(id: added_site_domains.map(&:id))
    end
  end

  def update_site_domain(site_domain, site_domain_attributes)
    transaction do
      normalize_site_domains if site_domain.update(site_domain_attributes)
    end
  end

  def normalize_site_domains
    all_site_domains = site_domains.reload.sort do |a, b|
      a.domain.length <=> b.domain.length
    end
    all_site_domains.each { |domain| domain.destroy unless domain.valid? }
  end

  def refresh_indexed_documents(scope)
    indexed_documents.select(:id).send(scope.to_sym).find_in_batches(batch_size: batch_size(scope)) do |batch|
      Resque.enqueue_with_priority(:low, AffiliateIndexedDocumentFetcher, id, batch.first.id, batch.last.id, scope)
    end
  end

  def unused_features
    features.any? ? Feature.where.not(id: features.collect(&:id)) : Feature.all
  end

  def has_organization_codes?
    agency.present? && agency.agency_organization_codes.any?
  end

  def should_show_job_organization_name?
    agency.blank? || agency.agency_organization_codes.empty? ||
      agency.agency_organization_codes.all?(&:is_department_level?)
  end

  def default_autodiscovery_url
    if website.present?
      website
    elsif site_domains.count == 1
      "http://#{site_domains.pick(:domain)}"
    end
  end

  def has_no_social_image_feeds?
    flickr_profiles.empty? && instagram_profiles.empty? &&
      (rss_feeds.mrss.empty? || rss_feeds.mrss.collect(&:rss_feed_urls).flatten.collect(&:oasis_mrss_name).compact.empty?)
  end

  def has_social_image_feeds?
    !has_no_social_image_feeds?
  end

  def searchable_twitter_ids
    affiliate_twitter_settings.includes(:twitter_profile).map do |ats|
      twitter_ids = [ats.twitter_profile.twitter_id]
      twitter_ids.push(ats.twitter_profile.twitter_lists.map(&:member_ids)) if ats.show_lists?
      twitter_ids
    end.flatten.uniq
  end

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:connections_attributes], :affiliate_name, :label) if params[:connections_attributes]
    update(params)
  end

  def enable_video_govbox!
    transaction do
      rss_feed = rss_feeds.managed.first_or_initialize(name: I18n.t(:videos, locale: locale))
      rss_feed.save!
      update_column(:is_video_govbox_enabled, true)
    end
  end

  def disable_video_govbox!
    transaction do
      rss_feed = rss_feeds.managed.first
      rss_feed&.destroy
      update_column(:is_video_govbox_enabled, false)
    end
  end

  def uses_custom_theme?
    theme != 'default'
  end

  def mobile_logo_url
    mobile_logo.url rescue 'unable to retrieve mobile logo url' if mobile_logo_file_name.present?
  end

  def last_month_query_count
    prev_month = Date.current.prev_month
    count_query = CountQuery.new(name, 'search')
    RtuCount.count(monthly_index_wildcard_spanning_date(prev_month, true),
                   count_query.body)
  end

  def user_emails
    users.map(&:to_label).join(',')
  end

  def to_label
    "##{id} #{display_name} (#{display_name}) [#{status}]"
  end

  def dup
    dup_instance = super
    dup_instance.css_property_hash = css_property_hash
    dup_instance
  end

  def status
    active? ? 'Active' : 'Inactive'
  end

  def excluded_urls_set
    @excluded_urls_set ||= excluded_urls.pluck(:url).map do |url|
      UrlParser.strip_http_protocols(url)
    end.uniq
  end

  private

  def batch_size(scope)
    (indexed_documents.send(scope.to_sym).size / fetch_concurrency.to_f).ceil
  end

  def remove_boosted_contents_from_index
    boosted_contents.each(&:remove_from_index)
  end

  def downcase_name
    self.name = name.downcase if name.present?
  end

  def set_default_labels
    self.rss_govbox_label = I18n.t(:default_rss_govbox_label, locale: locale) if rss_govbox_label.blank?
  end

  def strip_bing_v5_key
    self.bing_v5_key = bing_v5_key.present? ? bing_v5_key.strip : nil
  end

  def validate_css_property_hash
    return if @css_property_hash.blank?

    validate_font_family(@css_property_hash)
    validate_logo_alignment(@css_property_hash)
    validate_color_in_css_property_hash(@css_property_hash)
  end

  def validate_font_family(hash)
    errors.add(:base, 'Font family selection is invalid') if hash['font_family'].present? && !FontFamily.valid?(hash['font_family'])
  end

  def validate_logo_alignment(hash)
    errors.add(:base, 'Logo alignment is invalid') if hash['logo_alignment'].present? && !LogoAlignment.valid?(hash['logo_alignment'])
  end

  def validate_color_in_css_property_hash(hash)
    return if hash.blank?

    DEFAULT_CSS_PROPERTIES.each_key do |key|
      validate_color_property(key, hash[key])
    end
  end

  def validate_color_property(key, value)
    return unless key.to_s =~ /color$/ && value.present?

    errors.add(:base, "#{key.to_s.humanize} should consist of a # character followed by 3 or 6 hexadecimal digits") unless value =~ /^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$/
  end

  def set_managed_header_links
    return if @managed_header_links_attributes.nil?

    self.managed_header_links = []
    set_managed_links(@managed_header_links_attributes, managed_header_links)
  end

  def set_managed_footer_links
    return if @managed_footer_links_attributes.nil?

    self.managed_footer_links = []
    set_managed_links(@managed_footer_links_attributes, managed_footer_links)
  end

  def set_managed_no_results_pages_alt_links
    return if @managed_no_results_pages_alt_links_attributes.nil?

    self.managed_no_results_pages_alt_links = []
    set_managed_links(@managed_no_results_pages_alt_links_attributes, managed_no_results_pages_alt_links)
  end

  def set_managed_links(managed_links_attributes, managed_links)
    managed_links_attributes.values.sort_by { |link| link[:position].to_i }.each do |link|
      next if link[:title].blank? && link[:url].blank?

      url = link[:url]
      url = "http://#{url}" if url.present? && url !~ %r{^(http(s?)://|mailto:)}i
      managed_links << { position: link[:position].to_i, title: link[:title], url: url }
    end
  end

  def validate_managed_header_links
    validate_managed_links(managed_header_links, :header)
  end

  def validate_managed_footer_links
    validate_managed_links(managed_footer_links, :footer)
  end

  def validate_managed_no_results_pages_alt_links
    validate_managed_links(managed_no_results_pages_alt_links, :alternative)
  end

  def validate_managed_links(links, link_type)
    return if links.blank?

    add_blank_link_title_error = false
    add_blank_link_url_error = false
    links.each do |link|
      add_blank_link_title_error = true if link[:title].blank? && link[:url].present?
      add_blank_link_url_error = true if link[:title].present? && link[:url].blank?
    end
    errors.add(:base, "#{link_type.to_s.humanize} link title can't be blank") if add_blank_link_title_error
    errors.add(:base, "#{link_type.to_s.humanize} link URL can't be blank") if add_blank_link_url_error
  end

  def set_default_fields
    self.theme = THEMES.keys.first.to_s if theme.blank?
    @css_property_hash = ActiveSupport::OrderedHash.new if @css_property_hash.nil?
    true
  end

  def set_css_properties
    self.css_properties = @css_property_hash.to_json if @css_property_hash.present?
  end

  def language_valid
    errors.add(:base, 'Locale must be valid') unless Language.exists?(code: locale)
  end

  def html_columns_cannot_be_malformed
    %i[external_tracking_code footer_fragment].each do |field_name_symbol|
      value = send(field_name_symbol)
      next if value.blank?

      validation_results = validate_html(value)
      if validation_results[:has_malformed_html]
        error_message = "#{field_name_symbol.to_s.humanize} is invalid: #{validation_results[:error_message]}"
        errors.add(:base, error_message)
      end
    end
  end

  def validate_html(html)
    validate_html_results = {}
    has_banned_elements = false
    has_banned_attributes = false
    if html.present?
      html_doc = Nokogiri::HTML::DocumentFragment.parse(html)
      unless html_doc.errors.empty?
        validate_html_results[:has_malformed_html] = true
        validate_html_results[:error_message] = "#{html_doc.errors.join('. ')}." if html_doc.errors.present?
      end
      has_banned_elements = true if html_doc.css(BANNED_HTML_ELEMENTS_FROM_HEADER_AND_FOOTER.join(',')).present?
      has_banned_attributes = true if html_doc.xpath('*[@onload]').present?
    end
    validate_html_results[:has_banned_elements] = has_banned_elements
    validate_html_results[:has_banned_attributes] = has_banned_attributes
    validate_html_results
  end

  def update_error_keys
    swap_error_key(:"rss_feeds.base", :base)
    swap_error_key(:"site_domains.domain", :domain)
    swap_error_key(:"connections.connected_affiliate_id", :related_site_handle)
    swap_error_key(:"connections.label", :related_site_label)
  end

  def live_fields
    @live_fields ||= live_fields_json.blank? ? {} : JSON.parse(live_fields_json, symbolize_names: true)
  end

  def set_json_fields
    self.live_fields_json = ActiveSupport::OrderedHash[live_fields.sort].to_json
  end

  def load_css_properties
    return {} if css_properties.blank?

    JSON.parse(css_properties, symbolize_names: true)
  end

  def clear_existing_attachments
    if mobile_logo? && !mobile_logo.dirty? && mark_mobile_logo_for_deletion == '1'
      mobile_logo.clear
    end

    if header_tagline_logo? && !header_tagline_logo.dirty? && mark_header_tagline_logo_for_deletion == '1'
      header_tagline_logo.clear
    end
  end

  def set_search_labels
    self.default_search_label = I18n.t(:everything, locale: locale) if default_search_label.blank?
  end

  def set_api_access_key
    self.api_access_key = Digest::SHA256.base64digest("#{name}:#{Time.current.to_i}:#{rand}").tr('+/', '-_')
  end

  def generate_look_and_feel_css
    renderer = AffiliateCss.new(build_css_hash)
    self.mobile_look_and_feel_css = renderer.render_mobile_css
  end

  def build_css_hash
    css_hash = {}
    css_hash.merge!(css_property_hash) if css_property_hash(true)
    css_hash
  end

  def self.to_name_site_hash
    Hash[all.collect { |site| [site.name, site] }]
  end

  def validate_managed_no_results_pages_guidance_text
    return unless managed_no_results_pages_alt_links.present? && additional_guidance_text.blank?

    errors.add(:base, 'Additional guidance text is required when links are present.')
  end
end
