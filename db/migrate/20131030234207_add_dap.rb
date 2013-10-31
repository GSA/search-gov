class AddDap < ActiveRecord::Migration
  def change
    add_column :affiliates, :dap_enabled, :boolean, default: true, null: false
  end
end
