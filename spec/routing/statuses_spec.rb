require 'spec_helper'

describe 'routing to statuses' do
  it 'should correctly determine the affiliate name' do
    expect(get: '/dcv/usagov.txt').to route_to(
      controller: 'statuses',
      action: 'domain_control_validation',
      format: :text,
      affiliate: 'usagov'
    )
  end

  it 'should not allow other formats' do
    expect(get: '/dcv/usagov.html').not_to route_to(
      controller: 'statuses',
      action: 'domain_control_validation',
      format: :html,
      affiliate: 'usagov'
    )
  end

  it 'should tolerate affiliates with dots in their name' do
    expect(get: '/dcv/foo.bar.txt').to route_to(
      controller: 'statuses',
      action: 'domain_control_validation',
      format: :text,
      affiliate: 'foo.bar'
    )
  end
end
