# frozen_string_literal: true

require 'spec_helper'

describe DateFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      date_filter = described_class.new(label: 'Some label', enabled: true)
      expect(date_filter).to be_valid
    end

    it 'uses the default label if none is provided but enabled is true' do
      date_filter = described_class.new(enabled: true)
      expect(date_filter).to be_valid
      expect(date_filter.label).to eq('DateFilter')
    end

    context 'when label is blank and enabled is true' do
      it 'uses the default label' do
        date_filter = described_class.new(label: '', enabled: true)
        date_filter.save
        date_filter.reload

        expect(date_filter.label).to eq('DateFilter')
      end
    end

    it 'does not set a default label when not enabled' do
      date_filter = described_class.new(enabled: false, label: nil)
      date_filter.valid?

      expect(date_filter.label).to be_nil
    end

    it 'does not overwrite an existing label' do
      date_filter = described_class.new(enabled: true, label: 'Custom Label')
      date_filter.valid?

      expect(date_filter.label).to eq('Custom Label')
    end
  end
end