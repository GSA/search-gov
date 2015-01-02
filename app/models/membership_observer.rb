class MembershipObserver < ActiveRecord::Observer
  def after_destroy(membership)
    user = membership.user
    if user && user.affiliates.empty?
      user.set_approval_status_to_not_approved
      user.save!
      Emailer.user_approval_removed(user).deliver
    end
  end
end
