require 'spec_helper'

describe Admin::SearchConsumerTemplatesController do
  fixtures :users, :affiliates, :memberships

  let(:affiliate) { affiliates(:usagov_affiliate) }

  before do
    activate_authlogic
    UserSession.create({ email: users('affiliate_admin').email, password: 'admin' })
  end

  describe 'routing' do
    it { should route(:get, '/admin/affiliates/1/search_consumer_templates').to(action: :index, affiliate_id: 1) }
  end

  describe '#index' do
    it 'renders the SearchConsumerTemplates index page' do
      affiliate.update_attributes(search_consumer_search_enabled: true)
      get :index, affiliate_id: affiliate.id
      expect(assigns(:page_title)).to eq 'Search Consumer Templates'
      expect(assigns(:affiliate)).to eq affiliate
    end

    it 'displays an error if the affiliate is not search consumer enabled' do
      get :index, affiliate_id: affiliate.id
      expect(flash[:error]).to match("The affiliate exists, but Search Consumer is not activated.")
    end

    it 'displays an error if the affiliate_id is not valid' do
      get :index, affiliate_id: 9999
      expect(flash[:error]).to match("The affiliate ID does not exist.")
    end
  end

  describe "#update" do
    let(:update_params) do
      { affiliate_id: affiliate.id, selected: "Template::RoundedHeaderLink",
        selected_template_types: ["Template::Classic","Template::RoundedHeaderLink"] }
    end

    subject(:update_templates) { post :update, update_params  }

    it "updates the affiliate's available templates" do
      update_templates
      expect(affiliate.affiliate_templates.available.pluck(:template_class)).to match_array(["Template::Classic","Template::RoundedHeaderLink"])
    end

    it "updates the affiliate's selected template" do
      expect{ update_templates }
        .to change{ affiliate.reload.affiliate_template.template_class }
        .from("Template::Classic").to("Template::RoundedHeaderLink")
    end

    context "when the update is unsuccessful" do
      before do
        Affiliate.any_instance.stub(:update_template).with("Template::RoundedHeaderLink").and_return(false)
        update_templates
      end

      it 'displays an error message' do
        expect(flash[:error]).to eq("Unable to update templates.")
      end
    end
  end

  describe "#port_classic" do
    before { post :port_classic, affiliate_id: affiliate.id } 

    it { should redirect_to(admin_affiliate_search_consumer_templates_path) }
  end
end
