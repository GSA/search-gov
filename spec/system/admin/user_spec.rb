# frozen_string_literal: true

describe 'Super Admin Users' do
  let(:url) { '/admin/users' }

  it_behaves_like 'a page restricted to super admins'

  context 'when a super admin is logged in' do
    include_context 'log in super admin'

    describe 'active_scaffold list', :js do
      before { visit url }

      it 'is accessible' do
        within('h2') do
          expect(page).to have_content('Users')
        end
      end

      it 'has expected columns' do
        expected_headings = %I[
          email-column
          first_name-column
          last_name-column
          affiliate_names-column
          default_affiliate-column
          created_at-column
          updated_at-column
          approval_status-column
          actions
        ]

        within('.as_content') do
          expect(page).to have_table(with_rows: [expected_headings])
        end
      end
    end

    context 'when an export is triggered', :js do
      subject(:export) do
        visit url
        click_link('Export')
        click_button('Export')
      end

      let(:file) { 'users.csv' }

      after do
        sleep(0.5) unless File.exist?(file)
        FileUtils.rm_f(file) if File.exist?(file)
      end

      it 'is successful' do
        expect { export }.not_to raise_error
      end

      it 'exports a csv of users' do
        export
        Timeout.timeout(5) do
          sleep(0.1) until File.exist?(file)
        end
        expect(File).to exist(file)
      end
    end
  end
end
