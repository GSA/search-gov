class Navigation < ActiveRecord::Base
  belongs_to :affiliate
  belongs_to :navigable, :polymorphic => true
  scope :active, where(:is_active => true).includes(:navigable)

  def is_inactive?
    !is_active?
  end
end
