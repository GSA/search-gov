class DeleteFeatureAdmonishmentEmailTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.where("name='feature_admonishment'").delete_all
  end

  def down
  end
end
