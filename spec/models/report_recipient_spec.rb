require 'spec_helper'
describe ReportRecipient do
  fixtures :report_recipients

  before do
    @valid_attributes = {:email => "somebody@the.gov"}
  end

  it "should create a new instance given valid attributes" do
    ReportRecipient.create!(@valid_attributes)
  end

  it { should validate_presence_of :email }
  it { should validate_uniqueness_of(:email).case_insensitive }
end