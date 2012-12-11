class RemoveKeywordsFieldFromBoostedContents < ActiveRecord::Migration
  def up
    remove_column :boosted_contents, :keywords
  end

  def down
    add_column :boosted_contents, :keywords, :text
    BoostedContent.all.each do |boosted_content|
      boosted_content.update_attribute(:keywords, boosted_content.boosted_content_keywords.collect(&:value).join(',')) unless boosted_content.boosted_content_keywords.empty?
    end
  end
end
