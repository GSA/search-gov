# frozen_string_literal: true

require 'spec_helper'

describe Scheduled::SearchgovUrlCounterCultureFixCountsJob do
  it 'fixes SearchgovUrl counter culture counts' do
    expect(SearchgovUrl).to receive(:counter_culture_fix_counts)
    described_class.perform_now
  end
end
