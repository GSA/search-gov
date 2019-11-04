class ReSeedAffiliateYearlyReportEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['affiliate_yearly_report']
  end

  def self.down
    EmailTemplate.where(name: 'affiliate_yearly_report').destroy_all
  end
end
