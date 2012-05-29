class SeedNestedHeaderFooterCss < ActiveRecord::Migration
  def self.up
    Affiliate.where('(uses_one_serp = 0 OR uses_one_serp IS NULL) OR (uses_one_serp = 1 AND (uses_managed_header_footer = 0 OR uses_managed_header_footer IS NULL))').each do |a|
      a.save
    end
  end

  def self.down
  end
end
