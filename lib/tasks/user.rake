namespace :usasearch do
  namespace :user do
    desc 'Set site-less users to not_approved'
    task update_approval_status: :environment do
      User.approved_affiliate.select { |user| user.affiliates.empty? }.each do |user|
        user.set_approval_status_to_not_approved
        user.save!
        Emailer.user_approval_removed(user).deliver_now
        note = <<~NOTE.squish
          User #{user.id}, #{user.email}, is no longer associated with any sites,
          so their approval status has been set to "not_approved".
        NOTE

        Rails.logger.info(note)
      end
    end

    desc 'Set accounts that are not active for more than 90 days to not_approved'
    task update_inactive_approval_status: :environment do
      User.not_active.each do |user|
        user.set_approval_status_to_not_approved
        user.save!

        note = <<~NOTE.squish
          User #{user.id},  #{user.email}, has been inactive for 90 days, 
          so their status has been set to "not_approved".
        NOTE

        Rails.logger.info(note)
      end
    end
  end
end
