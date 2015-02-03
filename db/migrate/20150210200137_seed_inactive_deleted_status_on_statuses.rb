class SeedInactiveDeletedStatusOnStatuses < ActiveRecord::Migration
  def up
    Status.create!(name: 'inactive - deleted')
  end

  def down
    Status.where(name: 'inactive - deleted').delete_all
  end
end
