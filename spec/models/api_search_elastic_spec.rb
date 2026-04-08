# frozen_string_literal: true

require 'spec_helper'

describe ApiSearchElastic do
  let(:affiliate) { affiliates(:basic_affiliate) }
  subject(:search) { described_class.new(affiliate: affiliate) }

  describe '#as_json_result_hash' do
    let(:result) { double('result', thumbnail_url: 'https://search.gov/thumbnail.jpg') }
    let(:parent_result_hash) { { title: 'parent title', url: 'https://search.gov/parent_url' } }

    before do
      # To isolate the test to only the logic in ApiSearchElastic, we stub the
      # method on the parent class (SearchElasticEngine).
      allow_any_instance_of(SearchElasticEngine).to receive(:as_json_result_hash).with(result).and_return(parent_result_hash)
    end

    it 'merges the thumbnail_url into the hash from the parent class' do
      # We create an instance of the class we are testing
      instance = described_class.new(affiliate: affiliate)
      # We call the method, which will in turn call `super` (which is stubbed)
      final_hash = instance.as_json_result_hash(result)

      # We expect the final hash to be a merge of the parent's hash and the new key
      expect(final_hash).to eq({
        title: 'parent title',
        url: 'https://search.gov/parent_url',
        thumbnail_url: 'https://search.gov/thumbnail.jpg'
      })
    end
  end
end