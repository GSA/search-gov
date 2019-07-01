# frozen_string_literal: true

module UserApproval
  def self.set_to_not_approved(users, message, email = false)
    users.each do |user|
      user.set_approval_status_to_not_approved
      user.save!
      Emailer.user_approval_removed(user).deliver_now if email

      note = <<~NOTE.squish
        User #{user.id}, #{user.email}, #{message},
        so their approval status has been set to "not_approved".
      NOTE

      Rails.logger.info(note)
    end
  end
end
