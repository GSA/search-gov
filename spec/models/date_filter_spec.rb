# frozen_string_literal: true

require 'spec_helper'

describe DateFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      date_filter = described_class.new(label: 'Some label', enabled: true)
      expect(date_filter).to be_valid
    end

    it 'is invalid without a label when enabled' do
      date_filter = described_class.new(enabled: true)
      expect(date_filter).not_to be_valid
      expect(date_filter.errors[:label]).to include("can't be blank")
    end
  end
end