class ReloadAffiliateMonthlyReportEmailTemplateTwo < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates ['affiliate_monthly_report']
  end

  def down
  end
end
