# frozen_string_literal: true

namespace :usasearch do
  namespace :user do
    desc 'Set site-less users to not_approved'
    task update_approval_status: :environment do
      UserApproval.
        set_to_not_approved(
          User.approved_affiliate.select { |user| user.affiliates.empty? },
          'is no longer associated with any sites',
          true
        )
    end

    desc 'Set accounts that are not active for more than 90 days to not_approved'
    task update_not_active_approval_status: :environment do
      UserApproval.set_to_not_approved(User.approved.not_active,
                                       'has been not active for 90 days')
    end
  end
end
