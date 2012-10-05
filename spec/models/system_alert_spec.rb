require 'spec_helper'

describe SystemAlert do
  it { should validate_presence_of :message }
  it { should validate_presence_of :start_at }

  it 'should not allow invalid end date' do
    SystemAlert.new(:message => 'Maintenance',
                    :start_at => Date.current,
                    :end_at => Date.current.yesterday).should_not be_valid
  end
end
