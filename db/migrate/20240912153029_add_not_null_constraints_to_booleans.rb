class AddNotNullConstraintsToBooleans < ActiveRecord::Migration[7.1]
  def up
    # Set existing NULL values to appropriate defaults before adding the NOT NULL constraint
    Affiliate.where(is_sayt_enabled: nil).update_all(is_sayt_enabled: true)
    Affiliate.where(is_medline_govbox_enabled: nil).update_all(is_medline_govbox_enabled: false)
    Affiliate.where(is_related_searches_enabled: nil).update_all(is_related_searches_enabled: true)
    Affiliate.where(is_photo_govbox_enabled: nil).update_all(is_photo_govbox_enabled: false)
    Affiliate.where(use_redesigned_results_page: nil).update_all(use_redesigned_results_page: true)
    Affiliate.where(display_logo_only: nil).update_all(display_logo_only: false)
    Affiliate.where(show_vote_org_link: nil).update_all(show_vote_org_link: false)
    BoostedContent.where(match_keyword_values_only: nil).update_all(match_keyword_values_only: false)
    FeaturedCollection.where(match_keyword_values_only: nil).update_all(match_keyword_values_only: false)
    SaytSuggestion.where(is_protected: nil).update_all(is_protected: false)
    SearchgovDomain.where(js_renderer: nil).update_all(js_renderer: false)
    User.where(requires_manual_approval: nil).update_all(requires_manual_approval: false)

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

  def down
    change_column :affiliates, :is_sayt_enabled, :boolean, default: true, null: true
    change_column :affiliates, :is_medline_govbox_enabled, :boolean, default: false, null: true
    change_column :affiliates, :is_related_searches_enabled, :boolean, default: true, null: true
    change_column :affiliates, :is_photo_govbox_enabled, :boolean, default: false, null: true
    change_column :affiliates, :use_redesigned_results_page, :boolean, default: true, null: true
    change_column :affiliates, :display_logo_only, :boolean, default: false, null: true
    change_column :affiliates, :show_vote_org_link, :boolean, default: false, null: true
    change_column :boosted_contents, :match_keyword_values_only, :boolean, default: false, null: true
    change_column :featured_collections, :match_keyword_values_only, :boolean, default: false, null: true
    change_column :sayt_suggestions, :is_protected, :boolean, default: false, null: true
    change_column :searchgov_domains, :js_renderer, :boolean, default: false, null: true
    change_column :users, :requires_manual_approval, :boolean, default: false, null: true
  end
end
