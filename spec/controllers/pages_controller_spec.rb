require 'spec/spec_helper'

describe PagesController do

  %w(api program recalls search tos widgets).each do |page|
    context "on GET to /pages/#{page}" do
      before do
        get :show, :id => page
      end

      it "assigns @page_title" do
        assigns[:page_title].should_not be_nil
      end

      it "should render the template" do
        response.should be_success
        response.should render_template page
      end
    end
  end
end
