class SeedRssGovboxLabelOnAffiliates < ActiveRecord::Migration
  def up
    execute 'UPDATE affiliates set rss_govbox_label = "News" WHERE locale = "en"'
    execute 'UPDATE affiliates set rss_govbox_label = "Noticias" WHERE locale = "es"'
  end

  def down
  end
end
