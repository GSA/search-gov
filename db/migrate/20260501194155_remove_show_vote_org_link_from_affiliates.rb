class RemoveShowVoteOrgLinkFromAffiliates < ActiveRecord::Migration[7.1]
  def change
    remove_column :affiliates, :show_vote_org_link, :boolean
  end
end
