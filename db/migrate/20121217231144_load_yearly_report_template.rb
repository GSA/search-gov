class LoadYearlyReportTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates(['affiliate_yearly_report'])
  end

  def down
    EmailTemplate.delete_all(:name => 'affiliate_yearly_report')
  end
end
