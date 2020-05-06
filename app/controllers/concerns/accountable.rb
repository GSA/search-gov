# frozen_string_literal: true

require 'active_support/concern'

module Accountable
  def incomplete_account_error
    if current_user&.first_name.blank?
      current_user.errors[:first_name] << 'You must supply a first name'
    elsif current_user&.last_name.blank?
      current_user.errors[:last_name] << 'You must supply a last name'
    elsif current_user&.organization_name.blank?
      current_user.errors[:organization_name] << 'You must supply an organization name'
    end
  end

  def check_user_account_complete
    return if current_user&.complete?

    incomplete_account_error
    redirect_to(
      edit_account_path,
      flash: {
        error:
          'To complete your registration, please make sure First name, Last name, and '\
          'Government agency are not empty'
      }
    )
  end
end
