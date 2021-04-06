# frozen_string_literal: true

context 'when a user is logged in' do
  include_context 'log in site admin'

  context 'when the user is set to not_approved' do
    before do
      user.update!(approval_status: 'not_approved')
    end

    it 'prevents the user from visiting more pages' do
      visit new_site_path
      expect(page).to have_content('Security Notification')
    end
  end
end
