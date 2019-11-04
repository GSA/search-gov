class SeedFilteredPopularTermsEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['filtered_popular_terms_report']
  end

  def self.down
    EmailTemplate.where(name: 'filtered_popular_terms_report').destroy_all
  end
end
