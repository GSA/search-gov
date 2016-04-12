require 'spec_helper'

describe Admin::SearchConsumerTemplatesController do
  fixtures :users, :affiliates, :memberships

  before do
    activate_authlogic
    UserSession.create({ email: users('affiliate_admin').email, password: 'admin' })
  end

  describe '#index' do
    let(:affiliate) { affiliates(:usagov_affiliate) }

    it 'renders the SearchConsumerTemplates index page' do
      affiliate.search_consumer_search_enabled = true
      affiliate.save
      affiliate.affiliate_template # must load a template
      affiliate.affiliate_templates.make_available(["Template::RoundedHeaderLink"])
      get :index, affiliate_id: affiliate.id
      expect(assigns(:page_title)).to eq 'Search Consumer Templates'
      expect(assigns(:affiliate)).to eq affiliate
    end

    it 'returns if the affiliate_id is not a param' do
      get :index
    end

    it 'returns if the affiliate is not search consumer enabled' do
      get :index, affiliate_id: affiliate.id
      expect(assigns(:page_title)).to eq 'Search Consumer Templates'
      expect(assigns(:affiliate)).to eq affiliate
    end

    it 'returns if the affiliate_id is not valid' do
      get :index, affiliate_id: 9999
      expect(assigns(:affiliate)).to_not eq affiliate
    end
  end

  describe "#update" do
    let(:affiliate) { affiliates(:usagov_affiliate) }

    it "updates the Affiliate's templates" do
      affiliate.affiliate_template # must load a template
      post :update, affiliate_id: affiliate.id, selected: "Template::Classic", "selected-template-types" => ["Template::Classic"]
      expect(assigns(:affiliate)).to eq affiliate
    end

    it "attempts to remove the Affiliate's selected templates" do
      affiliate.affiliate_template # must load a template
      p affiliate.locale
      post :update, affiliate_id: affiliate.id, selected: "Template::Classic"
      expect(assigns(:affiliate)).to eq affiliate
    end
  end

  describe "#port_classic" do
    let(:affiliate) { affiliates(:usagov_affiliate) }

    it "updates the Affiliate's templates" do
      affiliate.affiliate_template # must load a template
      post :port_classic, affiliate_id: affiliate.id
      expect(assigns(:affiliate)).to eq affiliate
    end
  end
end
