class ReloadAffiliateMonthlyReportEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['affiliate_monthly_report']
  end

  def self.down
  end
end
