class CreateReportsRecipients < ActiveRecord::Migration
  def self.up
    create_table :report_recipients do |t|
      t.string :email, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :report_recipients
  end
end
