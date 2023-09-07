class AddLinksJsonToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :links_json, :json
  end
end
