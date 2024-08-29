require 'spec_helper'

describe UrlsController do
  let(:urls_example) { ['http://example.com'] }

  describe 'test controller #create' do
    it 'returns a JSON response with a job_id' do
      post :create, params: { urls: urls_example }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response.parsed_body).to have_key('job_id')
    end

    it 'enqueues a SearchgovUrlsJob with the provided URLs' do
      mock_scheduled_job = double
      allow(mock_scheduled_job).to receive(:job_id).and_return('12345')
      allow(SearchgovUrlsJob).to receive(:perform_later).and_return(mock_scheduled_job)
      post :create, params: { urls: urls_example }
      expect(SearchgovUrlsJob).to have_received(:perform_later).with(anything, urls_example)
    end

    it 'returns a 422 error if no URLs are provided' do
      post :create
      expect(response).to have_http_status('422')
      expect(response.body).to match(/The 'urls' parameter is required./)
    end
  end
end
