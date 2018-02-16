require 'spec_helper'

describe SystemAlert do
  it { is_expected.to validate_presence_of :message }
  it { is_expected.to validate_presence_of :start_at }

  it 'should not allow invalid end date' do
    expect(SystemAlert.new(message:  'Maintenance',
                    start_at: Date.current,
                    end_at:   Date.current.yesterday)).not_to be_valid
  end

  it 'should show a correct label' do
    alert = SystemAlert.new(message:  'Maintenance',
                    start_at: Time.new(2018, 1, 1, 0, 0, 0, '+00:00'),
                    end_at:   Time.new(2018, 1, 2, 0, 0, 0, '+00:00'))
    expect(alert.to_label).to eq('System Alert: "Maintenance", starting at 2018-01-01 00:00:00 UTC')
  end
end
