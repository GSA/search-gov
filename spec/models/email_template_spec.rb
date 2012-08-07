require 'spec_helper'

describe EmailTemplate do
  before do
    @valid_attributes = {
      :name => 'email_template',
      :subject => '[USASearch] ',
      :body => 'Hello, World.'
    }
  end

  it { should validate_presence_of :name }
  it { should validate_presence_of :subject }
  it { should validate_presence_of :body }
  it "should create a new instance given valid attributes" do
    EmailTemplate.create!(@valid_attributes)

    should validate_uniqueness_of :name
  end

  describe "#load_default_templates" do
    it "should load all the templates when no parameter is passed in" do
      EmailTemplate.load_default_templates
      EmailTemplate.count.should == 16
    end

    context "when specifying a specific set of templates" do
      it "should only reload those templates, and leave the rest alone" do
        EmailTemplate.count.should == 16
        before_time = Time.now
        sleep(1)
        EmailTemplate.load_default_templates(["affiliate_monthly_report", "mobile_feedback"])
        EmailTemplate.all(:conditions => ['created_at > ?', before_time]).size.should == 2
      end
    end
  end
end
