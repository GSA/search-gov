class ChangeDefaultSearchEngineToBingV7 < ActiveRecord::Migration
  def up
    change_column_default :affiliates, :search_engine, 'BingV7'
  end

  def down
    change_column_default :affiliates, :search_engine, 'BingV6'
  end
end
