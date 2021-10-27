# frozen_string_literal: true

describe 'ExcludedDomains', :js do
  let(:url) { '/admin/excluded_domains' }

  it_behaves_like 'a page restricted to super admins'

  context 'when there is an excluded domain' do
    before do
      ExcludedDomain.create(domain: 'test.gov',
                            affiliate: Affiliate.first)
    end

    it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'ExcludedDomains'
  end

  it_behaves_like 'a Search'
end
