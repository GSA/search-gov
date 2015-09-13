require 'spec_helper'

describe 'layouts/application' do
  before do
    assign :dashboard, double('RtuDashboard').as_null_object
  end

  it_behaves_like 'a non-prod git info banner'
end
