class MigrateAffiliateUsersToMemberships < ActiveRecord::Migration
  def up
    execute 'INSERT INTO memberships (affiliate_id, user_id) select affiliate_id, user_id from affiliates_users'
  end

  def down
    Membership.delete_all
  end
end
