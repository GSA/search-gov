shared_context 'log in super admin' do
  let(:user) { users(:affiliate_admin) }

  before { login(user) }
end

shared_context 'log in site admin' do
  let(:user) { users(:affiliate_manager) }

  before { login(user) }
end

shared_examples 'a page restricted to super admins' do
  before { visit url }

  context 'when no user is logged in' do
    it 'redirects to the system notification page' do
      expect(page).to have_content('Security Notification')
    end
  end

  context 'when a super admin is logged in' do
    include_context 'log in super admin'

    it 'is accessible' do
      expect(page).to have_content('Super Admin')
    end
  end

  context 'when a site admin is logged in' do
    include_context 'log in site admin'

    it 'redirects to the site administration page' do
      expect(page).not_to have_content('Super Admin')
      expect(page).to have_content('Add Site')
    end
  end
end
