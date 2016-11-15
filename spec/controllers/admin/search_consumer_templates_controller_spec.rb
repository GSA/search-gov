require 'spec_helper'

describe Admin::SearchConsumerTemplatesController do
  fixtures :users, :affiliates, :memberships

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:classic_template) { Template.find_by_klass('Classic') }
  let(:irs_template) { Template.find_by_klass('Irs') }
  let(:rounded_template) { Template.find_by_klass('RoundedHeaderLink') }

  before do
    activate_authlogic
    UserSession.create(users('affiliate_admin'))
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

    context 'when the affiliate is not search consumer enabled' do
      before { affiliate.update_attributes(search_consumer_search_enabled: false) }
      it 'displays an error' do
        get :index, affiliate_id: affiliate.id
        expect(flash[:error]).to match("The affiliate exists, but Search Consumer is not activated.")
      end
    end

    it 'displays an error if the affiliate_id is not valid' do
      get :index, affiliate_id: 9999
      expect(flash[:error]).to match("The affiliate ID does not exist.")
    end
  end

  describe "#update" do
    let(:update_params) do
      { affiliate_id: affiliate.id, selected: irs_template.id.to_s,
        selected_template_types: [irs_template.id.to_s, classic_template.id.to_s] }
    end

    let(:update_templates) { post :update, update_params  }

    it "updates the affiliate's available templates" do
      update_templates
      expect(affiliate.reload.available_templates.map(&:name)).to match_array(["Classic","IRS"])
    end

    it "updates the affiliate's selected template" do
      expect{ update_templates }
        .to change{ affiliate.reload.template.name }
        .from("Classic").to("IRS")
    end

    context 'when the selected template is not also visible' do
      before do
        post :update,
          { affiliate_id: affiliate.id, selected: rounded_template.id.to_s,
            selected_template_types: [irs_template.id.to_s, classic_template.id.to_s] }
      end

      it { should set_flash[:error].to("Please ensure the selected template is a visible template.") }
    end

    context 'when no templates have been made visible' do
      let(:update_params) do
        { affiliate_id: affiliate.id, selected: rounded_template.id.to_s }
      end
      before { update_templates }

      it { should set_flash[:error].to("Please ensure the selected template is a visible template.") }
    end

    context "when the update is unsuccessful" do
      before do
        Affiliate.any_instance.stub(:update_templates).with(anything, anything).and_return(false)
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
