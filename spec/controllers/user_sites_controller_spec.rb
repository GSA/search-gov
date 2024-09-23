require 'spec_helper'

describe UserSitesController do
  fixtures :users
  let(:current_user) { users(:affiliate_manager) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)

    2.times do |i|
      Affiliate.create!(
        name: "user_site_#{i}",
        display_name: "User Site #{i}",
        website: "http://example#{i}.com",
        users: [current_user]
      )
    end
  end

  describe 'GET #index' do
    context 'when rendering HTML' do
      it 'assigns @affiliates and renders the index template' do
        get :index, params: { page: 1 }

        expect(assigns(:affiliates)).to eq(current_user.affiliates.paginate(page: 1, per_page: 100))
        expect(response).to render_template(:index)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when rendering CSV' do
      it 'sends a CSV file with the correct filename' do
        get :index, params: { format: :csv }

        expected_filename = "affiliates-#{Time.zone.today}.csv"
        expect(response.headers['Content-Disposition']).to include("filename=\"#{expected_filename}\"")
        expect(response.content_type).to eq('text/csv')
        expect(response).to have_http_status(:ok)
      end

      it 'generates CSV with correct headers and data' do
        get :index, params: { format: :csv }

        csv = CSV.parse(response.body)

        expect(csv[0]).to eq(%w[id display_name site_handle admin_home_page homepage_url site_search_page])

        affiliate = current_user.affiliates.first
        expect(csv[1]).to eq([affiliate.id.to_s,
                              affiliate.display_name,
                              affiliate.name,
                              site_url(affiliate),
                              affiliate.website,
                              search_url(affiliate: affiliate.name)])
      end
    end
  end

  describe 'before_action :set_user' do
    it 'sets @user to the current user' do
      get :index
      expect(assigns(:user)).to eq(current_user)
      expect(response).to have_http_status(:ok)
    end
  end
end
