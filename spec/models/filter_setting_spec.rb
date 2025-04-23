# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FilterSetting, type: :model do
  describe 'Associations' do
    it { should belong_to(:affiliate) }
    it { should have_one(:topic).class_name('Filter') }
    it { should have_one(:file_type).class_name('Filter') }
    it { should have_one(:content_type).class_name('Filter') }
    it { should have_one(:audience).class_name('Filter') }
    it { should have_one(:date).class_name('Filter') }
    it { should have_one(:custom_1).class_name('CustomFilter') }
    it { should have_one(:custom_2).class_name('CustomFilter') }
    it { should have_one(:custom_3).class_name('CustomFilter') }
  end

  describe '#initialize_default_filters_preview' do
    subject(:filter_setting) { described_class.new }

    it 'returns dynamically generated default filters' do
      filters = filter_setting.initialize_default_filters_preview

      expect(filters.size).to eq(8) # 8 filters: 5 default + 3 custom
      expect(filters.map(&:label)).to match_array(%w[Topic FileType ContentType Audience Date Custom1 Custom2 Custom3])
      expect(filters.map(&:type)).to match_array(%w[TopicFilter FileTypeFilter ContentTypeFilter AudienceFilter DateFilter
                                                    CustomFilter CustomFilter CustomFilter])
      expect(filters.map(&:position)).to eq([0, 1, 2, 3, 4, 5, 6, 7])
      expect(filters.all? { |filter| filter.enabled == false }).to be(true)
    end
  end
end
