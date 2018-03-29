class AddWatcherEmailTemplates < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates(%w[
      watcher_low_query_ctr
      watcher_no_results
    ])
  end

  def down
  end
end
