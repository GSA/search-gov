require 'spec_helper'

describe AgencyOrganizationCode do
  describe '#to_label' do
    it 'returns the organization code' do
      expect(described_class.new(organization_code: 'foo').to_label).to eq 'foo'
    end
  end
end
