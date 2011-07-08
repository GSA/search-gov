require 'spec/spec_helper'

describe SendAffiliateBroadcast, "#perform(subject, body)" do
  before do
    @emailer = mock(Emailer)
    @emailer.stub!(:deliver).and_return true
  end

  it "should send emails to all affiliate users" do
    num_affiliates = User.where(:is_affiliate=>true).count
    AffiliateEmailer.should_receive(:email).exactly(num_affiliates).times.with(an_instance_of(User), "foo", "bar").and_return @emailer
    SendAffiliateBroadcast.perform("foo", "bar")
  end
end
