# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CustomFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      custom_filter = CustomFilter.new(label: 'Some label', enabled: true)
      expect(custom_filter).to be_valid
    end

    it 'is invalid without a label when enabled' do
      custom_filter = CustomFilter.new(enabled: true)
      expect(custom_filter).not_to be_valid
      expect(custom_filter.errors[:label]).to include("can't be blank")
    end

    it 'is valid without a label when not enabled' do
      custom_filter = CustomFilter.new(enabled: false)
      expect(custom_filter).to be_valid
    end
  end
end