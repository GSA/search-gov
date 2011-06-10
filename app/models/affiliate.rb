class Affiliate < ActiveRecord::Base
  validates_presence_of :display_name
  validates_presence_of :name
  validates_presence_of :search_results_page_title
  validates_presence_of :staged_search_results_page_title
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :within=> (3..33)
  validates_format_of :name, :with=> /^[a-z0-9._-]+$/
  has_and_belongs_to_many :users
  belongs_to :affiliate_template
  belongs_to :staged_affiliate_template, :class_name => 'AffiliateTemplate'
  has_many :boosted_contents, :dependent => :destroy
  has_many :spotlights, :dependent => :destroy
  has_many :sayt_suggestions, :dependent => :destroy
  has_many :superfresh_urls, :dependent => :destroy
  has_many :calais_related_searches, :dependent => :destroy
  after_destroy :remove_boosted_contents_from_index
  before_validation :set_default_name, :on => :create
  before_save :set_default_affiliate_template, :normalize_domains
  before_validation :set_default_search_results_page_title, :set_default_staged_search_results_page_title, :on => :create
  scope :ordered, {:order => 'display_name ASC'}
  
  USAGOV_AFFILIATE_NAME = 'usasearch.gov'
  VALID_RELATED_TOPICS_SETTINGS = %w{ affiliate_enabled global_enabled disabled }
  DEFAULT_SEARCH_RESULTS_PAGE_TITLE = "{Query} - {SiteName} Search Results"

  HUMAN_ATTRIBUTE_NAME_HASH = {
    :display_name => "Site name",
    :name => "HTTP parameter site name",
    :staged_search_results_page_title => "Search results page title"
  }

  def name=(name)
    new_record? ? (write_attribute(:name, name)) : (raise "This field cannot be changed.")
  end

  def is_affiliate_sayt_enabled?
    self.is_sayt_enabled && self.is_affiliate_suggestions_enabled
  end

  def is_global_sayt_enabled?
    self.is_sayt_enabled && !self.is_affiliate_suggestions_enabled
  end

  def is_sayt_disabled?
    !self.is_sayt_enabled && !self.is_affiliate_suggestions_enabled
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
    %w{ domains header footer affiliate_template_id search_results_page_title }.each do |field|
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
      :staged_search_results_page_title => self.staged_search_results_page_title
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

  class << self
    def human_attribute_name(attribute_key_name, options = {})
      HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
    end
  end

  private

  def remove_boosted_contents_from_index
    boosted_contents.each { |bs| bs.remove_from_index }
  end

  def set_default_affiliate_template
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
end
