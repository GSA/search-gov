namespace :usasearch do
  namespace :user do
    desc 'Set site-less users to not_approved'
    task update_approval_status: :environment do
      usasearch_user_set_user_not_approved(User.approved_affiliate,
                            'is no longer associated with any sites',
                            true)
    end

    desc 'Set accounts that are not active for more than 90 days to not_approved'
    task update_not_active_approval_status: :environment do
      usasearch_user_set_user_not_approved(User.approved.not_active, 'has been not active for 90 days')
    end
  end

  def usasearch_user_set_user_not_approved(users, message, email = false)
    users.each do |user|
      user.set_approval_status_to_not_approved
      user.save
      Emailer.user_approval_removed(user).deliver_now if email

      note = <<~NOTE.squish
        User #{user.id}, #{user.email}, #{message},
        so their approval status has been set to "not_approved".
      NOTE

      Rails.logger.info(note)
    end
  end
end
