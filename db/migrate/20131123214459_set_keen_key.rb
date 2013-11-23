class SetKeenKey < ActiveRecord::Migration
  def up
    Affiliate.all.each do |affiliate|
      affiliate.update_column(:keen_scoped_key, KeenScopedKey.generate(affiliate.id))
    end
  end

  def down
  end
end
