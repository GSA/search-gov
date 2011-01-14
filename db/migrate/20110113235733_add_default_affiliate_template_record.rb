class AddDefaultAffiliateTemplateRecord < ActiveRecord::Migration
  def self.up
    id = insert("insert into affiliate_templates (name, description, stylesheet) values ('Default', 'A minimal design with blue titles and green urls', 'default')")
    update("update affiliates set affiliate_template_id = #{id} where affiliate_template_id is null")
  end

  def self.down
    id = select_value("select id from affiliate_templates where stylesheet = 'default'")
    delete("delete from affiliate_templates where stylesheet = 'default'")

    update("update affiliates set affiliate_template_id = null where affiliate_template_id = #{id}")
  end
end
