require 'spec_helper'

describe ApiBlendedSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

  describe '#as_json' do
    subject(:search) do
      described_class.new affiliate: affiliate,
                          enable_highlighting: true,
                          limit: 20,
                          next_offset_within_limit: true,
                          offset: 0,
                          query: 'healthy snack'
    end

    it_should_behave_like 'an API search as_json'
  end
end
