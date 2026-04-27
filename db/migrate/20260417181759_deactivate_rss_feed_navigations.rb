class DeactivateRssFeedNavigations < ActiveRecord::Migration[7.1]
  def up
    Navigation.where(navigable_type: 'RssFeed').update_all(is_active: false)
  end

  def down
    # Intentionally no-op: re-activation should be done manually if needed
  end
end
