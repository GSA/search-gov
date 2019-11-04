class DestroyHostedSitemapsFeature < ActiveRecord::Migration
  def up
    Feature.where(internal_name: 'hosted_sitemaps').destroy_all
  end

  def down
    Feature.create(:internal_name => 'hosted_sitemaps', :display_name => 'Hosted sitemaps')
  end
end
