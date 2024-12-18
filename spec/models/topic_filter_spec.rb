# frozen_string_literal: true

require 'spec_helper'

describe TopicFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      topic_filter = described_class.new(label: 'Some label', enabled: true)
      expect(topic_filter).to be_valid
    end

    it 'is invalid without a label when enabled' do
      topic_filter = described_class.new(enabled: true)
      expect(topic_filter).not_to be_valid
      expect(topic_filter.errors[:label]).to include("can't be blank")
    end
  end
end