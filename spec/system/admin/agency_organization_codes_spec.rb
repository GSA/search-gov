# frozen_string_literal: true

describe 'Agency Organization Codes', :js do
  let(:url) { '/admin/agency_organization_codes' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'AgencyOrganizationCodes'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
