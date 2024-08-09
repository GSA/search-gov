class AddShowVoteOrgLinkToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :show_vote_org_link, :boolean, default: false
  end
end
