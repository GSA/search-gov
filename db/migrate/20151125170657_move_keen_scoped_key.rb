class MoveKeenScopedKey < ActiveRecord::Migration
  def up
    Affiliate.all.each do |a|
      ScopedKey.create!(affiliate_id: a.id, key: a.keen_scoped_key)
    end
  end

  def down
    ScopedKey.delete_all
  end
end
