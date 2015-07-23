class EmailTemplate < ActiveRecord::Base
  validates_presence_of :name, :subject, :body
  validates_uniqueness_of :name, case_sensitive: false

  DEFAULT_SUBJECT_HASH = {
      affiliate_header_footer_change: "[USASearch] Your header and footer for <%= @affiliate.display_name %> changed",
      affiliate_monthly_report: "[DigitalGov Search] Monthly Report for <%= Date::MONTHNAMES[@user_monthly_report.report_date.month.to_i] %> <%= @user_monthly_report.report_date.year %>",
      affiliate_yearly_report: "[USASearch] <%= @report_year %> Year in Review",
      daily_snapshot: "[USASearch] Today's Snapshot for <%= @site.name %> on <%= Date.yesterday %>",
      deep_collection_notification: "[USASearch] Deep collection created",
      filtered_popular_terms_report: "[USASearch] Filtered Popular Terms for Last Week",
      new_affiliate_site: "[USASearch] Your new site: <%= @affiliate.display_name %>",
      new_affiliate_user: "[USASearch] You've been added to <%= @affiliate.display_name %>",
      new_feature_adoption_to_admin: "[USASearch] Features adopted yesterday",
      new_user_email_verification: "[USASearch] Verify your email",
      new_user_to_admin: "[USASearch] New user sign up",
      password_reset_instructions: "[USASearch] Reset your password",
      public_key_upload_notification: "[USASearch] Request for log file access",
      update_external_tracking_code: "[USASearch] 3rd Party Tracking",
      user_sites: '[DigitalGov Search] Searchers now see your Federal Register notices and rules',
      welcome_to_new_user: "[USASearch] Welcome to USASearch",
      welcome_to_new_user_added_by_affiliate: "[USASearch] Welcome to USASearch",
      user_approval_removed: "[DigitalGov Search] User account set to 'not_approved'"
  }

  class << self

    def load_default_templates(template_list = [])
      emailer_directory = Dir.glob(Rails.root.to_s + "/db/email_templates/*")
      emailer_directory.each do |email_file|
        name = email_file.split("/").last.split(".").first
        next if template_list.any? and !template_list.include?(name)
        EmailTemplate.delete_all(["name=?", name])
        body = File.read(email_file)
        EmailTemplate.create!(name: name, subject: DEFAULT_SUBJECT_HASH[name.to_sym], body: body)
      end
    end
  end
end
