class AddEnqueuedForReindexToSearchgovUrls < ActiveRecord::Migration
  def change
    add_column :searchgov_urls,
               :enqueued_for_reindex,
               :boolean,
                default: false, null: false
  end
end
