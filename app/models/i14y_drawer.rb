class I14yDrawer < ActiveRecord::Base
  attr_accessible :affiliate_id, :description, :handle, :token
  belongs_to :affiliate
  validates_presence_of :handle, :affiliate_id
  validates_uniqueness_of :handle
  validates_length_of :handle, within: (3..33)
  validates_format_of :handle, with: %r(^[a-z0-9._]+$)
  before_validation :set_token, unless: :token?

  def label
    handle
  end

  private

  def set_token
    self.token = Digest::SHA256.base64digest("#{handle}:#{Time.current.to_i}:#{rand}").tr('+/', '-_')
  end

end
