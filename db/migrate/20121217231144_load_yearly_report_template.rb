class LoadYearlyReportTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates(['affiliate_yearly_report'])
  end

  def down
    EmailTemplate.where(name: 'affiliate_yearly_report').delete_all
  end
end
