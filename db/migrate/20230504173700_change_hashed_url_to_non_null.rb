class ChangeHashedUrlToNonNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :searchgov_urls, :hashed_url, false
  end
end
