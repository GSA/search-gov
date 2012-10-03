class DestroyHostedSitemapsFeature < ActiveRecord::Migration
  def up
    Feature.destroy_all(:internal_name => 'hosted_sitemaps')
  end

  def down
    Feature.create(:internal_name => 'hosted_sitemaps', :display_name => 'Hosted sitemaps')
  end
end
