require 'spec_helper'

describe JobsHelper do
  fixtures :affiliates

  describe '#format_salary' do
    it 'should return nil when minimum_pay is nil' do
      job = double('job', minimum_pay: nil, maximum_pay: nil, rate_interval_code: 'Per Year')
      expect(helper.format_salary(job)).to be_nil
    end

    it 'should return nil when minimum_pay is zero and maximum_pay is nil' do
      job = double('job', minimum_pay: 0, maximum_pay: nil, rate_interval_code: 'Per Hour')
      expect(helper.format_salary(job)).to be_nil
    end

    it 'should return salary when minimum_pay is not zero and maximum_pay is nil' do
      job = double('job', minimum_pay: 17.50, maximum_pay: nil, rate_interval_code: 'Per Hour')
      expect(helper.format_salary(job)).to eq('$17.50/hr')
    end

    it 'should return salary when the rate interval is not Per Year, Per Hour or Without Compensation' do
      job = double('job', minimum_pay: 17.50, maximum_pay: nil, rate_interval_code: 'Per Day')
      expect(helper.format_salary(job)).to eq('$17.50 Per Day')
    end

    it 'should return salary range when maximum_pay is not nil and the rate interval is not Per Year, Per Hour or Without Compensation' do
      job = double('job', minimum_pay: 17.50, maximum_pay: 20.50, rate_interval_code: 'Per Day')
      expect(helper.format_salary(job)).to eq('$17.50-$20.50 Per Day')
    end
  end

  describe '#job_application_deadline' do
    it 'should return nil when end date is nil' do
      expect(helper.job_application_deadline(nil)).to be_nil
    end
  end
end
