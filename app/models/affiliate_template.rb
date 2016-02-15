class AffiliateTemplate < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :affiliate
  validates_uniqueness_of :affiliate_id, scope: :template_class

  validates_presence_of(:template_class) {|at| at.template_class.constantize.is_a?(Template) }

  scope :available, where(available: true)

  def self.hidden
    all = Template::TEMPLATE_SUBCLASSES
    visible = self.available.map(&:template_class).map(&:constantize)
    (all - visible).map(&:new)
  end

  def human_readable_name
    template_class.constantize::HUMAN_READABLE_NAME
  end
end
