class SeedBlockedRegexps < ActiveRecord::Migration
  def self.up
    ["q(uery)=%22><a%20", "q(uery)=child%2520care&sitelimit=www\.tdprs", "q(uery)=space&sitelimit=science"].each do |regexp|
      LogfileBlockedRegexp.create!(:regexp => regexp)
    end
  end

  def self.down
    LogfileBlockedRegexp.delete_all
  end
end
