# frozen_string_literal: true

describe 'Users', :js do
  let(:url) { '/admin/users' }
  let(:downloaded_csv) { 'users.csv' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'a page that can export data'
  it_behaves_like 'an ActiveScaffold page', %w[Show Edit], 'Users'

  describe 'when a super admin is logged in' do
    include_context 'log in super admin'

    before { visit url }

    describe 'the headers' do
      let(:headers) { all('th').map(&:text).reject(&:blank?) }

      it 'are only the expected ones' do
        expect(headers).to eq(
          ['Email', 'First name', 'Last name', 'Memberships', 'Default affiliate',
           'Created at', 'Updated at', 'Approval status']
        )
      end
    end

    describe 'the user Show fields' do
      let(:user_detail_field_names) { page.find('.show-view').find_all('dt').map(&:text) }

      before do
        click_link('Show', match: :first)
        wait_for_ajax
      end

      it 'shows the correct user fields' do
        expect(user_detail_field_names).to eq(
          ['Email', 'First name', 'Last name', 'Memberships', 'Default affiliate',
           'Created at', 'Updated at', 'Approval status']
        )
      end
    end
  end
end
