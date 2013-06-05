class RemoveSauceLabsEmailTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.delete_all(:name => 'saucelabs_report')
  end

  def down
  end
end
