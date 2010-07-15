class CreateSessionRelatedQueries < ActiveRecord::Migration
  def self.up
    create_table :session_related_queries do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :session_related_queries
  end
end
