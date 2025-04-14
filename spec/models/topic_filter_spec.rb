# frozen_string_literal: true

require 'spec_helper'

describe TopicFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      topic_filter = described_class.new(label: 'Some label', enabled: true)
      expect(topic_filter).to be_valid
    end

    it 'uses the default label if none is provided but enabled is true' do
      topic_filter = described_class.new(enabled: true)
      expect(topic_filter).to be_valid
      expect(topic_filter.label).to eq('TopicFilter')
    end

    context 'when label is blank and enabled is true' do
      it 'uses the default label' do
        topic_filter = described_class.new(label: '', enabled: true)
        topic_filter.save
        topic_filter.reload

        expect(topic_filter.label).to eq('TopicFilter')
      end
    end

    it 'does not set a default label when not enabled' do
      topic_filter = described_class.new(enabled: false, label: nil)
      topic_filter.valid?

      expect(topic_filter.label).to be_nil
    end

    it 'does not overwrite an existing label' do
      topic_filter = described_class.new(enabled: true, label: 'Custom Label')
      topic_filter.valid?

      expect(topic_filter.label).to eq('Custom Label')
    end
  end
end