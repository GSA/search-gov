require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ClicksController do
  fixtures :affiliates

  describe "#create" do
    context "when key exists in cache" do
      before do
        @search = Search.new({:query => 'government', :affiliate => affiliates(:basic_affiliate) })
        @serp_position = 9
        @url = "http://www.someurl.com"
        @results_source = "some result source"
        key = @search.send(:cache, @url, @serp_position, @results_source)
        get :create, :key => key
      end

      it "should redirect to destination URL" do
        response.should redirect_to(@url)
      end

      it "should record the click" do
        click = Click.find_by_url_and_results_source_and_serp_position(@url, @results_source, @serp_position)
        click.query.should == @search.query
        click.affiliate.should == @search.affiliate.name
        click.queried_at.should_not be_nil
        click.clicked_at.should_not be_nil
      end
    end

    context "when key can't be found in cache" do
      it "should redirect to home page" do
        get :create, :key => "not gonna find me"
        response.should redirect_to(home_page_path)
      end

      it "should log a warning so we can track it" do
        RAILS_DEFAULT_LOGGER.should_receive(:warn)
        get :create, :key => "not gonna find me"
      end
    end

    context "when key isn't passed in" do
      it "should redirect to home page" do
        get :create
        response.should redirect_to(home_page_path)
      end
    end
  end
end
