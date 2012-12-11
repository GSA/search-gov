class ReindexBoostedContents < ActiveRecord::Migration
  def up
    BoostedContent.reindex
    Sunspot.commit
  end

  def down
  end
end
