# frozen_string_literal: true

class EmailTemplate < ApplicationRecord
  validates_presence_of :name, :subject, :body
  validates_uniqueness_of :name, case_sensitive: false

  DEFAULT_SUBJECT_HASH = {
      affiliate_header_footer_change: "[Search.gov] Your header and footer for <%= @affiliate.display_name %> changed",
      affiliate_monthly_report: "[Search.gov] Monthly Report for <%= Date::MONTHNAMES[@user_monthly_report.report_date.month.to_i] %> <%= @user_monthly_report.report_date.year %>",
      affiliate_yearly_report: '[Search.gov] <%= @report_year %> Year in Review',
      daily_snapshot:
        "[Search.gov] Today's Snapshot for <%= @site.name %> on <%= Date.yesterday %>",
      deep_collection_notification: '[Search.gov] Deep collection created',
      filtered_popular_terms_report: '[Search.gov] Filtered Popular Terms for Last Week',
      new_affiliate_site: "[Search.gov] Your new site: <%= @affiliate.display_name %>",
      new_affiliate_user:
        "[Search.gov] You've been added to <%= @affiliate_display_name %>",
      new_feature_adoption_to_admin: '[Search.gov] Features adopted yesterday',
      user_email_verification: '[Search.gov] Verify your email',
      new_user_to_admin: '[Search.gov] New user sign up',
      password_reset_instructions: '[Search.gov] Reset your password',
      update_external_tracking_code: '[Search.gov] 3rd Party Tracking',
      user_sites: '[Search.gov] Searchers now see your Federal Register notices and rules',
      welcome_to_new_user: '[Search.gov] Welcome to Search.gov',
      welcome_to_new_user_added_by_affiliate: '[Search.gov] Welcome to Search.gov',
      user_approval_removed: "[Search.gov] User account set to 'not_approved'",
      low_query_ctr_watcher: '[Search.gov] {{ctx.metadata.alert_name}} (Custom Alert)',
      no_results_watcher: '[Search.gov] {{ctx.metadata.alert_name}} (Custom Alert)',
      account_deactivation_warning:
        '[Search.gov] Your Search.gov account expires soon: Log in today to keep access'
  }.freeze

  class << self

    def load_default_templates(template_list = [])
      emailer_directory = Dir.glob(Rails.root.to_s + "/db/email_templates/*")
      emailer_directory.each do |email_file|
        name = email_file.split("/").last.split(".").first
        next if template_list.any? and !template_list.include?(name)
        EmailTemplate.where(['name=?', name]).delete_all
        body = File.read(email_file)
        EmailTemplate.create!(name: name, subject: DEFAULT_SUBJECT_HASH[name.to_sym], body: body)
      end
    end
  end
end
