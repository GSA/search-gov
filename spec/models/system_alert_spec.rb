require 'spec_helper'

describe SystemAlert do
  it { should validate_presence_of :message }
  it { should validate_presence_of :start_at }

  it 'should not allow invalid end date' do
    SystemAlert.new(message:  'Maintenance',
                    start_at: Date.current,
                    end_at:   Date.current.yesterday).should_not be_valid
  end

  it 'should show a correct label' do
    alert = SystemAlert.new(message:  'Maintenance',
                    start_at: Time.new(2018, 1, 1, 0, 0, 0, '+00:00'),
                    end_at:   Time.new(2018, 1, 2, 0, 0, 0, '+00:00'))
    alert.to_label.should eq('System Alert: "Maintenance", starting at 2018-01-01 00:00:00 UTC')
  end
end
