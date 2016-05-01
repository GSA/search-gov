class AffiliateTemplate < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection # included by default in Rails 4

  belongs_to :affiliate
  validates_presence_of :affiliate_id
  validates_uniqueness_of :affiliate_id, scope: :template_class

  validates :template_class, inclusion: { in: Template::TEMPLATE_SUBCLASSES.map(&:name),
                                          allow_nil: false }

  scope :available, where(available: true)

  def self.hidden
    all = Template::TEMPLATE_SUBCLASSES
    visible = self.available.pluck(:template_class).map(&:constantize)
    (all - visible)
  end

  def human_readable_name
    template_class.constantize::HUMAN_READABLE_NAME
  end
end
