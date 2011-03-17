require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Emailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  describe "#objectionable_content_alert" do
    before(:all) do
      @email = Emailer.deliver_objectionable_content_alert("foo@bar.com", %w{ baaaaad awful })
    end

    it "should be set to be delivered to the email passed in" do
      @email.should deliver_to("foo@bar.com")
    end

    it "should have the correct subject" do
      @email.should have_subject(/Objectionable Content Alert/)
    end

    it "should contain search links for each term" do
      @email.should have_body_text(/baaaaad/)
      @email.should have_body_text(/awful/)
    end

  end

  describe "#saucelabs_report" do
    before(:all) do
      @url = "http://cdn.url"
      @email = Emailer.deliver_saucelabs_report("foo@bar.com", @url)
    end

    it "should be set to be delivered to the email passed in" do
      @email.should deliver_to("foo@bar.com")
    end

    it "should have the correct subject" do
      @email.should have_subject(/Sauce Labs Report/)
    end

    it "should contain URL to report" do
      @email.should have_body_text(/#{@url}/)
    end

  end
end
