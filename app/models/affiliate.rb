class Affiliate < ActiveRecord::Base
  validates_presence_of :display_name
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :within=> (3..33)
  validates_format_of :name, :with=> /^[a-z0-9._-]+$/
  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :users
  belongs_to :affiliate_template
  has_many :boosted_contents, :dependent => :destroy
  has_many :sayt_suggestions, :dependent => :destroy
  has_many :calais_related_searches, :dependent => :destroy
  after_destroy :remove_boosted_contents_from_index
  before_validation_on_create :set_default_name
  before_save :set_default_affiliate_template
  after_create :add_owner_as_user

  USAGOV_AFFILIATE_NAME = 'usasearch.gov'
  VALID_RELATED_TOPICS_SETTINGS = %w{affiliate_enabled global_enabled disabled}

  HUMAN_ATTRIBUTE_NAME_HASH = {
    :display_name => "Site name",
    :name => "HTTP parameter site name"
  }

  def is_owner?(user)
    self.owner == user ? true : false
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

  class << self
    def human_attribute_name(attribute_key_name, options = {})
      HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
    end
  end

  private

  def remove_boosted_contents_from_index
    boosted_contents.each { |bs| bs.remove_from_index }
  end
  
  def add_owner_as_user
    self.users << self.owner if self.owner
  end

  def set_default_affiliate_template
    self.staged_affiliate_template_id = AffiliateTemplate.default_id if staged_affiliate_template_id.blank?
    self.affiliate_template_id = AffiliateTemplate.default_id if affiliate_template_id.blank?
  end

  def set_default_name
    if self.name.blank?
      self.name = self.display_name.downcase.gsub(/[^a-z0-9._-]/, '')[0,33] unless self.display_name.blank?
      self.name = nil if !self.name.blank? and self.name.length < 3
      self.name = nil if !self.name.blank? and Affiliate.find_by_name(self.name)
      self.name = Digest::MD5.hexdigest("#{self.owner_id}:#{Time.now.to_s}")[0..8] if self.name.blank?
    end
  end
end
