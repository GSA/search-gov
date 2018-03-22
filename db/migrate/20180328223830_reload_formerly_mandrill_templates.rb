class ReloadFormerlyMandrillTemplates < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates(%w[
      new_affiliate_user
      password_reset_instructions
      user_email_verification
      welcome_to_new_user
      welcome_to_new_user_added_by_affiliate
    ])
  end

  def down
  end
end
