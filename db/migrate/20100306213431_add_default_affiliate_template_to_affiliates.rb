class AddDefaultAffiliateTemplateToAffiliates < ActiveRecord::Migration
  class AffiliateTemplate < ActiveRecord::Base;end
  
  def self.up
    Affiliate.update_all("affiliate_template_id = #{AffiliateTemplate.first.id}")
  end

  def self.down
    Affiliate.update_all("affiliate_template_id = NULL")
  end
end
