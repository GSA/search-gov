class AssignShowContentBorderAndBoxShadowOnAffiliates < ActiveRecord::Migration
  def self.up
    Affiliate.where(:uses_one_serp => true).select { |a| a.header.blank? and a.footer.blank? }.each do |a|
      a.css_property_hash[:show_content_border] = '1'
      a.css_property_hash[:show_content_box_shadow] = '1'
      a.save!
    end
  end

  def self.down
  end
end
