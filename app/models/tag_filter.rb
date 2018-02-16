class TagFilter < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :affiliate_id, :tag
  validates_uniqueness_of :tag, scope: :affiliate_id, case_sensitive: false
  scope :excluded, -> { where(exclude: true) }
  scope :required, -> { where(exclude: false) }
end
