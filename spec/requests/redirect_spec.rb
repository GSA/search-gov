require 'spec_helper'

shared_examples "a redirect to searchblog" do
  before { get "#{path}" }
  subject { response }
  it { should redirect_to('http://usasearch.howto.gov') }
  its(:status) { should == Rack::Utils.status_code(:found) }
end

describe "/program" do
  let(:path) { '/program' }
  it_should_behave_like "a redirect to searchblog"
end
