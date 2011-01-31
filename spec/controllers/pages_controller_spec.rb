require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do

  %w(accessibility api program recalls search textsize tos widgets).each do |page|
    context "on GET to /pages/#{page}" do
      before do
        get :show, :id => page
      end

      it "assigns @page_title" do
        assigns[:page_title].should_not be_nil
      end

      should_respond_with :success
      should_render_template page
    end
  end
end
