require 'spec/spec_helper'

describe AffiliateEmailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  fixtures :affiliates, :users

  describe "#email(affiliate_user, subject, body)" do
    let(:affiliate) { affiliates(:power_affiliate) }
    let(:affiliate_user) { affiliate.users.first }
    let(:email) { AffiliateEmailer.email(affiliate_user, "emailsubject", "emailbody") }

    it "should be sent to the invitee" do
      email.should deliver_to(affiliate_user.email)
    end

    it "should have the subject set" do
      email.should have_subject(/emailsubject/)
    end

    it "should have the body set inside the template somewhere" do
      email.should have_body_text(/emailbody/)
    end

    it "should contain a list of all the user's affiliates in the body" do
      affiliate_user.affiliates.each { |affiliate| email.should have_body_text(/#{affiliate.name}/) }
    end
  end
end
