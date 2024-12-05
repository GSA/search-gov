# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Filter, type: :model do
  describe 'Associations' do
    it { should belong_to(:filter_setting) }
  end
end