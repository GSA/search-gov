class SeedFilteredPopularTermsEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['filtered_popular_terms_report']
  end

  def self.down
    EmailTemplate.destroy_all(:name => 'filtered_popular_terms_report')
  end
end
