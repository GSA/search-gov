# frozen_string_literal: true

require 'spec_helper'

describe OpenSearchConfig do
  describe 'crawler index writes flag' do
    # .env.test defaults this to true; restore after each ENV example.
    after { ENV['OPENSEARCH_CRAWLER_INDEX_WRITES_ENABLED'] = 'true' }

    {
      nil => true,
      '' => true,
      'true' => true,
      'TRUE' => true,
      '1' => true,
      'false' => false,
      'FALSE' => false,
      ' False ' => false
    }.each do |value, expected|
      it "treats ENV #{value.inspect} as enabled=#{expected}" do
        if value.nil?
          ENV.delete('OPENSEARCH_CRAWLER_INDEX_WRITES_ENABLED')
        else
          ENV['OPENSEARCH_CRAWLER_INDEX_WRITES_ENABLED'] = value
        end

        expect(described_class.crawler_index_writes_enabled?).to eq(expected)
        expect(described_class.crawler_index_writes_disabled?).to eq(!expected)
      end
    end
  end
end
