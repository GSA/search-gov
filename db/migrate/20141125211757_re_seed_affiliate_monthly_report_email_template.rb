class ReSeedAffiliateMonthlyReportEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['affiliate_monthly_report']
  end

  def self.down
    EmailTemplate.where(name: 'affiliate_monthly_report').destroy_all
  end
end
