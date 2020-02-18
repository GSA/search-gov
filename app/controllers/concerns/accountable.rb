# frozen_string_literal: true

require 'active_support/concern'

module Accountable
  def incomplete_account_error
    if current_user&.contact_name.blank?
      current_user.errors[:contact_name] << 'You must supply a contact name'
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
          'To complete your registration, please make sure Name, and '\
          'Government agency are not empty'
      }
    )
  end
end
