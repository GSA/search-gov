require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do

  %w(accessibility).each do |page|
    context "on GET to /pages/#{page}" do
      before do
        get :show, :id => page
      end

      should_respond_with :success
      should_render_template page
    end
  end
end
