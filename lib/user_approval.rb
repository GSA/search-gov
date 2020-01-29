# frozen_string_literal: true

module UserApproval
  def self.warn_set_to_not_approved(users, date)
    users.each do |user|
      Emailer.account_deactivation_warning(user, date).deliver_now
    end
  end

  def self.set_to_not_approved(users, message, email_type = '')
    users.each do |user|
      user.set_approval_status_to_not_approved
      user.save!

      send_not_approved_email(email_type, user)

      note = <<~NOTE.squish
        User #{user.id}, #{user.email}, #{message},
        so their approval status has been set to "not_approved".
      NOTE

      Rails.logger.info(note)
    end
  end

  def self.send_not_approved_email(email_type, user)
    if email_type == 'siteless'
      Emailer.user_approval_removed(user).deliver_now
    elsif email_type == 'inactive'
      Emailer.account_deactivated(user)
    end
  end
end
