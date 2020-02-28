# frozen_string_literal: true

namespace :usasearch do
  namespace :user do
    desc 'Set site-less users to not_approved'
    task update_approval_status: :environment do
      UserApproval.
        set_to_not_approved(
          User.approved_affiliate.select { |user| user.affiliates.empty? },
          'is no longer associated with any sites',
          'siteless'
        )
    end

    desc 'Set accounts that are not active for more than 90 days to not_approved'
    task update_not_active_approval_status: :environment do
      UserApproval.set_to_not_approved(User.approved.not_active,
                                       'has been not active for 90 days',
                                       'inactive')
    end

    desc 'Warns not active users account will be deactivated'
    task :warn_set_to_not_approved, [:number_of_days] => [:environment] do |_t, args|
      date = args.number_of_days.to_i.days.ago
      UserApproval.warn_set_to_not_approved(User.
        not_active_since(date.to_date), date.to_date)
    end
  end
end
