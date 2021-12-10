# frozen_string_literal: true

shared_context 'log in super admin' do
  let(:user) { users(:affiliate_admin) }

  before { login(user) }
end

shared_context 'log in site admin' do
  let(:user) { users(:affiliate_manager) }

  before { login(user) }
end

shared_examples_for 'a page restricted to super admins' do |expected_content = 'Super Admin'|
  context 'when no user is logged in' do
    before { visit url }

    it 'redirects to the system notification page' do
      expect(page).to have_content('Security Notification')
    end
  end

  context 'when a super admin is logged in' do
    include_context 'log in super admin'

    before { visit url }

    it 'is accessible' do
      expect(page).to have_content(expected_content)
    end

    context 'when the super admin is set to not_approved' do
      it 'prevents the user from accessing additional pages' do
        user.update!(approval_status: 'not_approved')
        visit url
        expect(page).to have_content('Security Notification')
      end
    end
  end

  context 'when a site admin is logged in' do
    include_context 'log in site admin'

    before { visit url }

    it 'redirects to the site administration page' do
      expect(page).not_to have_content('Super Admin')
      expect(page).to have_content('Add Site')
    end
  end
end
