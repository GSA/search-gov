require 'spec_helper'

shared_examples "a redirect to searchblog" do
  before { get "#{path}" }
  subject { response }
  it { is_expected.to redirect_to('https://search.gov') }
  its(:status) { should == Rack::Utils.status_code(:found) }
end

describe "/program" do
  let(:path) { '/program' }
  it_should_behave_like "a redirect to searchblog"
end

describe "routes for Affiliates" do
  it "routes /affiliates/:id/path to the sites controller for that affiliate" do
    get "/affiliates/1234/path"
    expect(response).to redirect_to("/sites/1234")
  end

  it "routes /affiliates/:id to the sites controller for that affiliate" do
    get "/affiliates/1234"
    expect(response).to redirect_to("/sites/1234")
  end

  it "routes /affiliates to the sites controller" do
    get "/affiliates"
    expect(response).to redirect_to("/sites")
  end
end
