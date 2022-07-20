# frozen_string_literal: true

describe 'Super Admin Users' do
  let(:url) { '/admin/users' }

  it_behaves_like 'a page restricted to super admins'

  context 'when a super admin is logged in' do
    include_context 'log in super admin'

    describe 'Users list', :js do
      before { visit url }

      it 'is accessible' do
        within('h2') do
          expect(page).to have_content('Users')
        end
      end

      it 'has expected columns' do
        expected_headings = [
          'Email',
          'First name',
          'Last name',
          'Affiliate names',
          'Default affiliate',
          'Created at',
          'Updated at',
          'Approval status'
        ]

        within('.as_content') do
          expected_headings.each do |h|
            expect(page).to have_css('th', text: h)
          end
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
