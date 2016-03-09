class AddCssHashToTemplateRoundedHeaderLink < ActiveRecord::Migration
  def change
        add_column :template_rounded_header_links, :css_hash, :text
  end
end
