# frozen_string_literal: true

describe 'HelpLinks', :js do
  let(:url) { '/admin/help_links' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'

  context 'when there is a help link' do
    before do
      HelpLink.create(help_page_url: 'https://test.gov',
                      request_path: '/ferd')
    end

    it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'HelpLinks'
  end
end
