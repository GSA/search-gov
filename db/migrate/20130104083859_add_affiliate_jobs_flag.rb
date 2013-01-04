class AddAffiliateJobsFlag < ActiveRecord::Migration
  def change
    add_column :affiliates, :jobs_enabled, :boolean, :null => false, :default => false
  end
end
