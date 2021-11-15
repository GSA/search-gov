# frozen_string_literal: true

describe 'Resque web' do
  let(:url) { '/admin/resque' }

  # Resque-web is mounted within the /admin namespace, and is expected to have similar
  # restrictions to other super admin pages. However, because it is a Sinatra app mounted
  # within our Rails app, both the behavior and implementation may diverge. Proceed with
  # caution when attempting to share code and/or specs...
  it_behaves_like 'a page restricted to super admins', 'Resque'

  context 'when the user is not logged in' do
    context 'when visiting a subpage' do
      let(:url) { '/admin/resque/some_other_page' }

      it 'redirects the user to the login page' do
        visit url
        expect(page).to have_content 'Security Notification'
      end
    end
  end

  context 'when a super admin is logged in' do
    include_context 'log in super admin'

    before { visit url }

    it 'includes the resque-scheduler tabs' do
      expect(page).to have_content('Schedule')
      expect(page).to have_content('Delayed')
    end

    context 'when visiting the resque scheduler page' do
      let(:url) { '/admin/resque/schedule' }

      it 'displays the list of scheduled jobs' do
        expect(page).to have_content 'The list below contains all scheduled jobs'
      end
    end
  end
end
