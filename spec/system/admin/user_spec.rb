# frozen_string_literal: true

describe 'Super Admin Users' do
  let(:url) { '/admin/users' }

  it_behaves_like 'a page restricted to super admins'

  context 'when a super admin is logged in' do
    include_context 'log in super admin'

    context 'when an export is triggered', :js do
      subject(:export) do
        visit url
        click_link('Export')
        click_button('Export')
      end

      let(:file) { 'users.csv' }

      after { FileUtils.rm_f(file) }

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
