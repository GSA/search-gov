class DropReportRecipients < ActiveRecord::Migration
  def change
    drop_table :report_recipients
  end
end
