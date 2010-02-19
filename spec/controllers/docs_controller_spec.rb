require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DocsController do
  before do
    get :show, :path => ["docs", "accessibility"]
  end

  describe "#show" do
    it "should render the appropriate action based on the path" do
      params_from(:get, "/docs/foobar").should == {:controller => "docs", :action => "show", :path => ["docs", "foobar"]}
    end

    should_render_template 'docs/accessibility.html.haml', :layout => 'docs'
  end
end
