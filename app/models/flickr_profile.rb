class FlickrProfile < ActiveRecord::Base
  attr_readonly :url, :profile_type, :profile_id
  belongs_to :affiliate

  before_validation :assign_profile_type_and_profile_id,
                    on: :create,
                    if: :url?

  validates_presence_of :affiliate_id, :url
  validates_presence_of :profile_type, :profile_id,
                        on: :create,
                        if: :url?,
                        message: 'invalid Flickr URL'
  validates_inclusion_of :profile_type,
                         on: :create,
                         in: %w{user group},
                         if: :profile_type?
  validates_uniqueness_of :profile_id,
                          on: :create,
                          scope: [:affiliate_id, :profile_type],
                          case_sensitive: false,
                          message: 'has already been added',
                          if: Proc.new { |fp| fp.affiliate_id? && fp.profile_type? && fp.profile_id? }

  after_create :notify_oasis
  scope :users, where(profile_type: 'user')
  scope :groups, where(profile_type: 'group')

  private

  def assign_profile_type_and_profile_id
    NormalizeUrl.new :url
    detect_profile_type
    lookup_and_assign_profile_id if profile_type.present?
  end

  def detect_profile_type
    self.profile_type =
        case url
          when %r[/photos/] then 'user'
          when %r[/groups/] then 'group'
        end
  end

  def lookup_and_assign_profile_id
    lookup_method = "lookup#{profile_type.capitalize}"
    self.profile_id = flickr.urls.send(lookup_method, url: url)['id'] rescue nil
  end

  def notify_oasis
    Oasis.subscribe_to_flickr(self.profile_id, self.url.sub(/\/$/,'').split('/').last, self.profile_type)
  end

end
