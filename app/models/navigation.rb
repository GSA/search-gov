class Navigation < ActiveRecord::Base
  belongs_to :affiliate
  belongs_to :navigable, :polymorphic => true
  scope :active, where(:is_active => true)
end
