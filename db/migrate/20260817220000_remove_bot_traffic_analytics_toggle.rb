class RemoveBotTrafficAnalyticsToggle < ActiveRecord::Migration[7.1]
  def up
    EmailTemplate.load_default_templates %w[affiliate_monthly_report affiliate_yearly_report]
    remove_column :users, :sees_filtered_totals
  end

  def down
    add_column :users, :sees_filtered_totals, :boolean, null: false, default: true
  end
end
