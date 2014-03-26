class DisableAgencyGovbox < ActiveRecord::Migration
  def up
    execute 'update affiliates set is_agency_govbox_enabled=0'
  end

  def down
  end
end
