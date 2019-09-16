class AffiliateTemplate < ApplicationRecord
  belongs_to :affiliate, inverse_of: :affiliate_templates
  belongs_to :template, inverse_of: :affiliate_templates
  validates_presence_of :affiliate_id, :template_id
  validates_uniqueness_of :affiliate_id, scope: :template_id
end
