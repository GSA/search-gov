# frozen_string_literal: true

describe '/api/search' do
  let(:endpoint) { '/api/search' }

  before { get endpoint }

  it 'returns a 404' do
    expect(response.status).to eq 404
  end

  it 'provides a useful message' do
    expect(response.body).to match(/This API endpoint has been deprecated/)
  end
end
