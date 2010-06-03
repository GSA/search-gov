require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ClicksController do
  describe "#create" do
    before do
      @request.env['REMOTE_ADDR'] = '1.2.3.4'
      get :create,
          :u=>"http://localhost:3000/search?locale=en&m=false&query=electrocoagulation++%29++%28site%3Awww.uspto.gov+%7C+site%3Aeipweb.uspto.gov%29+",
          :q=>"some query",
          :t=> "1271978905",
          :a=>"some affiliate",
          :p=>"7",
          :s=>"results source"
    end

    it "should return success" do
      response.should be_success
    end

    it "should record the click" do
      click = Click.last
      click.query.should == "some query"
      click.url.should == "http://localhost:3000/search?locale=en&m=false&query=electrocoagulation++)++(site:www.uspto.gov+|+site:eipweb.uspto.gov)+"
      click.serp_position.should == 7
      click.results_source.should == "results source"
      click.affiliate.should == "some affiliate"
      click.queried_at.to_i.should == 1271978905
      click.clicked_at.should_not be_nil
      click.user_agent.should == 'Rails Testing'
      click.click_ip.should == '1.2.3.4'
    end
  end
end
