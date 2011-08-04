require 'spec/spec_helper'

describe EmbeddedSearchesController do
  describe "#index" do
    before do
      get :index
    end

    it { should_not render_template("layouts/application") }
  end
end