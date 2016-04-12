require 'spec_helper'

describe Sites::TemplatesController do
  fixtures :users, :affiliates, :memberships, :affiliate_templates
  before { activate_authlogic }

  describe '#edit' do
  end

  describe '#update' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template) { affilaite_templates(:usagov_classic) }

    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create current_user
        User.should_receive(:find_by_id).and_return(current_user)
      end

      it "should update the template" do
        affiliate.affiliate_template
        put :update,
            site_id: affiliate.id,
            id: 100,
            template_class: "Template::Classic"
            response.should redirect_to  :edit_site_template
      end

      it "should not update the template if the type is not valid or active" do
        affiliate.affiliate_template
        put :update,
            site_id: affiliate.id,
            id: 100,
            template_type: "Template::NotValid"
            response.should render_template :edit
      end
    end
  end
end
