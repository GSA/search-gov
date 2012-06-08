class EmailTemplate < ActiveRecord::Base
  validates_presence_of :name, :subject, :body
  validates_uniqueness_of :name

  DEFAULT_SUBJECT_HASH = {
      :password_reset_instructions => '[USASearch] Password Reset Instructions',
      :new_user_to_admin => '[USASearch] New user signed up for USA Search Services',
      :new_feature_adoption_to_admin => '[USASearch] Features adopted by customers yesterday',
      :feature_admonishment => '[USASearch] Getting started with USASearch features',
      :new_user_email_verification => '[USASearch] Email Verification',
      :welcome_to_new_user => '[USASearch] Welcome to the USASearch Affiliate Program',
      :welcome_to_new_developer => '[USASearch] Welcome to the USASearch Program: APIs and Web Services',
      :mobile_feedback => '[USASearch] <%= I18n.t(:mobile_feedback_subject) %>',
      :new_affiliate_site => '[USASearch] Your new site: <%= @affiliate.display_name %>',
      :new_affiliate_user => '[USASearch] USASearch Affiliate Program: You Were Added to <%= @affiliate.display_name %>',
      :welcome_to_new_user_added_by_affiliate => '[USASearch] Welcome to the USASearch Affiliate Program',
      :saucelabs_report => '[USASearch] Sauce Labs Report',
      :objectionable_content_alert => '[USASearch] Objectionable Content Alert',
      :affiliate_header_footer_change => '[USASearch] The header and footer for <%= @affiliate.display_name %> have been changed',
      :affiliate_monthly_report => '[USASearch] Monthly Search Analytics Report for <%= Date::MONTHNAMES[@report_date.month.to_i] %> <%= @report_date.year %>',
      :update_external_tracking_code => '[USASearch] 3rd Party Tracking'
  }

  class << self

    def load_default_templates(template_list = [])
      emailer_directory = Dir.glob(Rails.root.to_s + "/db/email_templates/*")
      emailer_directory.each do |email_file|
        name = email_file.split("/").last.split(".").first
        next if template_list.any? and !template_list.include?(name)
        EmailTemplate.delete_all(["name=?", name])
        body = File.read(email_file)
        EmailTemplate.create!(:name => name, :subject => DEFAULT_SUBJECT_HASH[name.to_sym], :body => body)
      end
    end
  end
end
