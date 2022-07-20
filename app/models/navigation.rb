class Navigation < ApplicationRecord
  belongs_to :affiliate
  belongs_to :navigable, :polymorphic => true
  scope :active, -> { where(:is_active => true).includes(:navigable) }

  def is_inactive?
    !is_active?
  end

  def navigable_facet_type
    navigable.respond_to?(:navigable_facet_type) ? navigable.navigable_facet_type : navigable.class.name
  end
end
