require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasswordResetsController do

  context "when unknown token is passed in" do
    it "should redirect to the home page" do
      get :edit, :id=>"fail"
      response.should redirect_to(home_page_path)
    end
  end

end
