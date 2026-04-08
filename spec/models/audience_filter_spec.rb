# frozen_string_literal: true

require 'spec_helper'

describe AudienceFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      audience_filter = described_class.new(label: 'Some label', enabled: true)
      expect(audience_filter).to be_valid
    end

    it 'uses the default label if none is provided but enabled is true' do
      audience_filter = described_class.new(enabled: true)
      expect(audience_filter).to be_valid
      expect(audience_filter.label).to eq('AudienceFilter')
    end

    context 'when label is blank and enabled is true' do
      it 'uses the default label' do
        audience_filter = described_class.new(label: '', enabled: true)
        audience_filter.save
        audience_filter.reload

        expect(audience_filter.label).to eq('AudienceFilter')
      end
    end

    it 'does not set a default label when not enabled' do
      audience_filter = described_class.new(enabled: false, label: nil)
      audience_filter.valid?

      expect(audience_filter.label).to be_nil
    end

    it 'does not overwrite an existing label' do
      audience_filter = described_class.new(enabled: true, label: 'Custom Label')
      audience_filter.valid?

      expect(audience_filter.label).to eq('Custom Label')
    end
  end
end
