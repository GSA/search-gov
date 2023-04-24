# frozen_string_literal: true

require 'spec_helper'

describe Search do
  describe '.new' do
    subject(:search) { described_class.new(options) }

    let(:options) { { affiliate: affiliates(:usagov_affiliate) } }

    it 'has no normalized results' do
      expect(search.normalized_results).to eq([])
    end

    it 'has zero total pages' do
      expect(search.total_pages).to eq(0)
    end
  end
end
