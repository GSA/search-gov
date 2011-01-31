require "#{File.dirname(__FILE__)}/../../spec_helper"

describe Admin::AffiliatesHelper do
  describe "#options_for_association_conditions" do
    fixtures :affiliates, :users
    it "should load users for the current affiliate as possible owners" do
      basic_affiliate = affiliates(:basic_affiliate)
      basic_affiliate.users << users(:another_affiliate_manager)
      helper.instance_variable_set :@record, basic_affiliate

      conditions = helper.options_for_association_conditions(Affiliate.reflections[:owner])

      User.find(:all, :conditions => conditions).should =~ [users(:affiliate_manager), users(:another_affiliate_manager )]
    end
  end
end
