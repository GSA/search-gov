class AddNotNullConstraintsToBooleans < ActiveRecord::Migration[7.1]
  def change
    change_column :affiliates, :is_sayt_enabled, :boolean, default: true, null: false
    change_column :affiliates, :is_medline_govbox_enabled, :boolean, default: false, null: false
    change_column :affiliates, :is_related_searches_enabled, :boolean, default: true, null: false
    change_column :affiliates, :is_photo_govbox_enabled, :boolean, default: false, null: false
    change_column :affiliates, :use_redesigned_results_page, :boolean, default: true, null: false
    change_column :affiliates, :display_logo_only, :boolean, default: false, null: false
    change_column :affiliates, :show_vote_org_link, :boolean, default: false, null: false
    change_column :boosted_contents, :match_keyword_values_only, :boolean, default: false, null: false
    change_column :featured_collections, :match_keyword_values_only, :boolean, default: false, null: false
    change_column :sayt_suggestions, :is_protected, :boolean, default: false, null: false
    change_column :searchgov_domains, :js_renderer, :boolean, default: false, null: false
    change_column :users, :requires_manual_approval, :boolean, default: false, null: false
  end
end
