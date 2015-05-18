class MoveI14yToHasManyThrough < ActiveRecord::Migration
  def up
    I14yDrawer.all.each do |i14y_drawer|
      I14yMembership.create!(affiliate: i14y_drawer.affiliate, i14y_drawer: i14y_drawer)
    end
  end

  def down
    I14yMembership.delete_all
  end
end
