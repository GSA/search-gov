require 'spec/spec_helper'

describe "Clicked" do
  context "when correct information is passed in" do
    before do
      get '/clicked',
          :u=>"http://localhost:3000/search?locale=en&m=false&query=electrocoagulation++%29++%28site%3Awww.uspto.gov+%7C+site%3Aeipweb.uspto.gov%29+",
          :q=>"some query",
          :t=> "1271978905",
          :a=>"some affiliate",
          :p=>"7",
          :s=>"results source"
    end

    it "should return success with a blank message body" do
      response.success?.should be(true)
      response.body.should == ''
    end

    it "should record the click" do
      click = Click.last
      click.query.should == "some query"
      click.url.should == "http://localhost:3000/search?locale=en&m=false&query=electrocoagulation++)++(site:www.uspto.gov+|+site:eipweb.uspto.gov)+"
      click.serp_position.should == 7
      click.results_source.should == "results source"
      click.affiliate.should == "some affiliate"
      click.queried_at.to_i.should == 1271978905
      click.clicked_at.should_not == nil
      click.click_ip.should == '127.0.0.1'
    end
  end

  context "when click url is missing" do
    before do
      get '/clicked',
          :q=>"some query",
          :t=> "1271978905",
          :a=>"some affiliate",
          :p=>"7",
          :s=>"results source"
    end

    it "should return success with a blank message body" do
      response.success?.should be(true)
      response.body.should == ''
    end
  end

end