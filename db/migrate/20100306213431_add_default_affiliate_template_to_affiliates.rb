class AddDefaultAffiliateTemplateToAffiliates < ActiveRecord::Migration
  def self.up
    affiliate_template = AffiliateTemplate.create(:name => "Default",
                                                  :description => "A simple, clean gray page",
                                                  :stylesheet  => "default")
    Affiliate.update_all("affiliate_template_id = #{affiliate_template.id}")
  end

  def self.down
    Affiliate.update_all("affiliate_template_id = NULL")
  end
end
