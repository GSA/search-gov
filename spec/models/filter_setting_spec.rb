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
end