require 'spec/spec_helper'

shared_examples "a redirect to searchblog" do
  before { get "#{path}" }
  subject { response }
  it { should redirect_to('http://searchblog.usa.gov') }
  its(:status) { should == Rack::Utils.status_code(:found) }
end

describe "/program" do
  let(:path) { '/program' }
  it_should_behave_like "a redirect to searchblog"
end

describe "/affiliates/demo" do
  let(:path) { '/affiliates/demo' }
  it_should_behave_like "a redirect to searchblog"
end

describe "/affiliates/how_it_works" do
  let(:path) { '/affiliates/how_it_works' }
  it_should_behave_like "a redirect to searchblog"
end
