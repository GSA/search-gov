require 'spec_helper'

describe Sites::TemplatesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#edit' do
  end

  describe '#update' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template) { Template.find_by_name("IRS") }
    let(:update_template) do
      put :update, site_id: affiliate.id, site: { template_id: template.id }
    end

    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when logged in as affiliate' do
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create current_user
        User.should_receive(:find_by_id).and_return(current_user)
      end

      context 'when the update is successful' do
        before { update_template }

        it "updates the template" do
          expect(affiliate.reload.template.name).to eq 'IRS'
        end

        it { should redirect_to(edit_site_template_path) }
      end

      context 'when something goes wrong' do
        before do
          Affiliate.any_instance.stub(:update_attributes).with(anything).and_return(false)
          update_template
        end

        it { should render_template(:edit) }
      end
    end
  end
end
