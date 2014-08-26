class LoadUserSitesEmailTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates ['user_sites']
  end

  def down
  end
end
