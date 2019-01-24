class I14yDrawer < ActiveRecord::Base
  has_many :i14y_memberships, dependent: :destroy
  has_many :affiliates, through: :i14y_memberships
  validates_presence_of :handle
  validates_uniqueness_of :handle
  validates_length_of :handle, within: (3..33)
  validates_format_of :handle, with: %r(\A[a-z0-9_]+\z), message: "must only contain lowercase letters, numbers, and underscore characters"
  before_validation :set_token, unless: :token?

  def label
    handle
  end

  def stats
    I14yCollections.get(handle).collection
  rescue StandardError => error
    Rails.logger.error(
      "Trouble fetching statistics for the #{handle} drawer:\n" \
      "#{error.class}: #{error}"
    )
    nil
  end

  def i14y_connection
    @i14y_connection ||= I14y.establish_connection!(user: handle, password: token)
  end

  private

  def set_token
    self.token = SecureRandom.hex(16)
  end
end
