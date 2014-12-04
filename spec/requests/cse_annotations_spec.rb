require 'spec_helper'

describe '/cse_annotations/index.xml' do
  fixtures :cse_annotations

  before do
    get '/cse_annotations/index.xml'
  end

  it "returns XML of the annotations" do
    expect(response.status).to eq(200)
    expect(response.content_type).to eq('application/xml')
  end

end