require 'spec_helper'

describe BingV6FormattedQuery do
  subject { described_class.new('') }

  describe '#query_plus_locale' do
    it 'simply returns the given query with no locale added' do
      expect(subject.query_plus_locale(:query)).to eq(:query)
    end
  end
end
