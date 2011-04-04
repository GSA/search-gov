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
  
  describe "#monthly_report" do
    before do
      @email = Emailer.deliver_monthly_report(File.join(RAILS_ROOT, "README.markdown"), Date.current)
    end
    
    it "should be sent to the monthly report recipients" do
      @email.should deliver_to(MONTHLY_REPORT_RECIPIENTS)
    end
    
    it "should have a subject with the file name in it" do
      @email.should have_subject("[USASearch] Monthly Report data attached: README.markdown")
    end
    
    it "should attach a file" do
      @email.parts.should contain(/README.markdown/)
    end
    
    it "should have an attachment" do
      @email.attachments.should_not be_empty
    end    
  end
end
