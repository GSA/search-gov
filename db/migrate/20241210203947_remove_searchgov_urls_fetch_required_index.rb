class RemoveSearchgovUrlsFetchRequiredIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :searchgov_urls, name: :searchgov_urls_fetch_required, if_exists: true
  end
end
