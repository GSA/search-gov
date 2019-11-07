class RemoveSauceLabsEmailTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.where(name: 'saucelabs_report').delete_all
  end

  def down
  end
end
