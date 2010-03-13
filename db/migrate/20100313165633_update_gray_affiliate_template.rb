class UpdateGrayAffiliateTemplate < ActiveRecord::Migration
  class AffiliateTemplate < ActiveRecord::Base;end
  def self.up
    if template = AffiliateTemplate.find_by_name("Default")
      template.update_attributes(
        :name => "Basic Gray",
        :stylesheet => "basic_gray"
      )
    end
    Affiliate.update_all("affiliate_template_id = NULL")
  end

  def self.down
    if template = AffiliateTemplate.find_by_name("Basic Gray")
      template.update_attributes(
        :name => "Default",
        :stylesheet => "default"
      )
    end
    Affiliate.update_all("affiliate_template_id = #{template.id}")
  end
end
