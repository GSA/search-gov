require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "shared/_search.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:query).and_return nil
    @search.stub!(:filter_setting).and_return nil
    @search.stub!(:scope_id).and_return nil
    assigns[:search] = @search
  end

  context "when page is displayed" do

    it "should display a link to the advanced search page" do
      render :locals => { :search => @search }
      response.should contain(/Advanced Search/)
    end

    context "for an affiliate site" do
      before do
        @affiliate = stub('Affiliate')
        @affiliate.stub!(:name).and_return 'aff.gov'
        assigns[:affiliate] = @affiliate
      end

      it "should not display a link to the advanced search page" do
        render :locals => { :search => @search, :affiliate => @affiliate }
        response.should_not contain(/Advanced Search/)
      end

    end
  end

end