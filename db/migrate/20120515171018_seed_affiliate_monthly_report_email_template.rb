class SeedAffiliateMonthlyReportEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ["affiliate_monthly_report"]
  end

  def self.down
    EmailTemplate.destroy_all("name='affiliate_monthly_report'")
  end
end
