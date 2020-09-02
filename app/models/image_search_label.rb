class ImageSearchLabel < ApplicationRecord
  belongs_to :affiliate
  has_one :navigation, :as => :navigable, :dependent => :destroy

  validates_presence_of :affiliate_id
  before_save :set_name, :if => Proc.new { |label| label.name.blank? }

  accepts_nested_attributes_for :navigation

  private
  def set_name
    self.name = I18n.t(:images, :locale => affiliate.locale)
  end
end
