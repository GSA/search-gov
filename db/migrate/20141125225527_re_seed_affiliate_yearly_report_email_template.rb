class ReSeedAffiliateYearlyReportEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['affiliate_yearly_report']
  end

  def self.down
    EmailTemplate.destroy_all(:name => 'affiliate_yearly_report')
  end
end
