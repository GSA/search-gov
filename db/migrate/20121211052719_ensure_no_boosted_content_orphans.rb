class EnsureNoBoostedContentOrphans < ActiveRecord::Migration
  def up
    BoostedContent.all.each do |boosted_content|
      boosted_content.destroy if boosted_content.affiliate.nil?
    end
  end

  def down
  end
end
