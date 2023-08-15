class AddVisualDesignJsonToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :visual_design_json, :json
  end
end
