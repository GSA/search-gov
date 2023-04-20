class AddIndicesToSearchgovUrlsEnqueuedForReindexAndLastmod < ActiveRecord::Migration[7.0]
  def change
    add_index :searchgov_urls, :enqueued_for_reindex
    add_index :searchgov_urls, :lastmod
  end
end
