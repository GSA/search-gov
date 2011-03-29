class SeedBlockedQueries < ActiveRecord::Migration
  def self.up
    ['enter keywords', 'cheesewiz', 'cheeseman', 'clusty', '1', 'test', 'search'].each do |query|
      LogfileBlockedQuery.create!(:query => query)
    end
  end

  def self.down
    LogfileBlockedQuery.delete_all
  end
end
