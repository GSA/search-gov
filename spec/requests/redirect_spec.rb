require 'spec_helper'

shared_examples "a redirect to searchblog" do
  before { get "#{path}" }
  subject { response }
  it { should redirect_to('https://search.gov') }
  its(:status) { should == Rack::Utils.status_code(:found) }
end

describe "/program" do
  let(:path) { '/program' }
  it_should_behave_like "a redirect to searchblog"
end

describe "routes for Affiliates" do
  it "routes /affiliates/:id/path to the sites controller for that affiliate" do
    get "/affiliates/1234/path"
    response.should redirect_to("/sites/1234")
  end

  it "routes /affiliates/:id to the sites controller for that affiliate" do
    get "/affiliates/1234"
    response.should redirect_to("/sites/1234")
  end

  it "routes /affiliates to the sites controller" do
    get "/affiliates"
    response.should redirect_to("/sites")
  end
end
