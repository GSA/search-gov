class AddTemplateTypeToAffiliate < ActiveRecord::Migration
  def change
    add_column :affiliates, :template_type, :string
  end
end
