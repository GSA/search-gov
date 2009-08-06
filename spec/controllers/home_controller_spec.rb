require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  it "should assign a search object" do
    get :index
    assigns[:search].should_not be_nil
  end

end
