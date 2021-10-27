# frozen_string_literal: true

describe 'OutboundRateLimits', :js do
  let(:url) { '/admin/outbound_rate_limits' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit], 'OutboundRateLimits'
end
