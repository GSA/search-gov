require 'spec_helper'

describe 'error pages' do
  describe 'unmatched routes' do
    it 'redirects to the invalid affiliate page with the original query string' do
      get '/unmatched-route', params: { affiliate: 'va', query: 'diabetes' }

      expect(response).to redirect_to('/errors/invalid-affiliate?affiliate=va&query=diabetes')
    end
  end

  describe 'GET /errors/invalid-affiliate.html' do
    it 'renders the invalid affiliate message in the search layout with a 404 status' do
      get '/errors/invalid-affiliate.html', params: { affiliate: 'missing', query: 'weather' }

      expect(response).to have_http_status(:not_found)
      expect(response).to render_template('layouts/searches_redesign')
      expect(response.body).to include('<title>Your search did not work</title>')
      expect(response.body).to include('data-react-class="ErrorPage"')
      expect(response.body).to include('The affiliate ID of the SearchGov site was either missing or invalid.')
    end
  end

  describe 'GET /errors/inactive-affiliate.html' do
    it 'renders the inactive affiliate message in the search layout with a 404 status' do
      get '/errors/inactive-affiliate.html', params: { affiliate: 'inactive', query: 'gov' }

      expect(response).to have_http_status(:not_found)
      expect(response).to render_template('layouts/searches_redesign')
      expect(response.body).to include('<title>Search Temporarily Unavailable</title>')
      expect(response.body).to include('data-react-class="ErrorPage"')
      expect(response.body).to include('This U.S. government search page has been turned off.')
    end
  end
end
