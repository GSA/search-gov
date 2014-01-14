class SeedStatuses < ActiveRecord::Migration
  class Status < ActiveRecord::Base
  end

  def up
    unless Rails.env.test?
      Status.reset_column_information
      Status.destroy_all
      active = Status.new(name: 'active')
      active.id = 1
      active.save!

      inactive = Status.new(name: 'inactive')
      inactive.id = 2
      inactive.save!
    end
  end

  def down
  end
end
