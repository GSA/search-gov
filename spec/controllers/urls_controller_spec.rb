require 'spec_helper'

describe UrlsController do
  urls_example = ['http://example.com']
  describe '#create' do
    it 'returns a JSON response with a job ID' do
      post :create, params: { urls: urls_example }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)).to have_key('job_id')
    end

    it 'enqueues a SearchgovUrlsJob with the provided URLs' do
      expect(SearchgovUrlsJob).to receive(:perform_later).with(anything, urls_example)
      post :create, params: { urls: urls_example }
    end

    it 'returns a 422 error if no URLs are provided' do
      post :create
      expect(response.status).to eq(422)
      expect(response.body).to match(/The 'urls' parameter is required./)
    end
  end

  describe '#create' do
    it 'enqueues a SearchgovUrlsJob and calls perform_later() method' do
      expect(SearchgovUrlsJob).to receive(:perform_later)
      post :create, params: { urls: urls_example }
    end
  end
end
