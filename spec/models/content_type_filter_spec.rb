# frozen_string_literal: true

require 'spec_helper'

describe ContentTypeFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      content_type_filter = described_class.new(label: 'Some label', enabled: true)
      expect(content_type_filter).to be_valid
    end

    it 'uses the default label if none is provided but enabled is true' do
      content_type_filter = described_class.new(enabled: true)
      expect(content_type_filter).to be_valid
      expect(content_type_filter.label).to eq('ContentTypeFilter')
    end

    context 'when label is blank and enabled is true' do
      it 'uses the default label' do
        content_type_filter = described_class.new(label: '', enabled: true)
        content_type_filter.save
        content_type_filter.reload

        expect(content_type_filter.label).to eq('ContentTypeFilter')
      end
    end

    it 'does not set a default label when not enabled' do
      content_type_filter = described_class.new(enabled: false, label: nil)
      content_type_filter.valid?

      expect(content_type_filter.label).to be_nil
    end

    it 'does not overwrite an existing label' do
      content_type_filter = described_class.new(enabled: true, label: 'Custom Label')
      content_type_filter.valid?

      expect(content_type_filter.label).to eq('Custom Label')
    end
  end
end