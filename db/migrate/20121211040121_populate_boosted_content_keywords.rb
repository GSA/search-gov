class PopulateBoostedContentKeywords < ActiveRecord::Migration
  def up
    BoostedContent.all.each do |boosted_content|
      if boosted_content.keywords.present?
        boosted_content.keywords.split(',').each do |str|
          keyword = str.strip
          boosted_content.boosted_content_keywords.build(:value => keyword) unless keyword.blank?
        end
        boosted_content.save
      end
    end
  end

  def down
    BoostedContentKeyword.delete_all
  end
end
