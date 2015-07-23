class DeleteFeatureAdmonishmentEmailTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.delete_all("name='feature_admonishment'")
  end

  def down
  end
end
