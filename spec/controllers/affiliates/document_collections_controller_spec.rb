require 'spec_helper'

describe Affiliates::DocumentCollectionsController do
  fixtures :affiliates, :users
  before do
    activate_authlogic
  end

  describe "#create" do
    context "when deep document collection created" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        @emailer = mock("Emailer")
      end

      it 'should notify the admin about it' do
        Emailer.should_receive(:deep_collection_notification).with(current_user, an_instance_of(DocumentCollection)).and_return @emailer
        @emailer.should_receive(:deliver)
        post :create, :document_collection => {
          :name => 'NPS only',
          :url_prefixes_attributes => {'0' => {:prefix => 'http://www.nps.gov/photos-and-video/'},
                                       '1' => {:prefix => 'http://www.nps.gov/blog/is/deep'}}
        }
      end
    end
  end
end
