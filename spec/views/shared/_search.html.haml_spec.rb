require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "shared/_search.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:query).and_return nil
    @search.stub!(:filter_setting).and_return nil
    @search.stub!(:scope_id).and_return nil
    @search.stub!(:fedstates).and_return nil
    assigns[:search] = @search
  end

  context "when page is displayed" do

    it "should display a link to the advanced search page" do
      render :locals => { :path => search_path, :search => @search }
      response.should contain(/Advanced Search/)
    end

    context "for an affiliate site" do
      before do
        @affiliate = stub('Affiliate')
        @affiliate.stub!(:name).and_return 'aff.gov'
        @affiliate.stub!(:is_sayt_enabled).and_return false
        assigns[:affiliate] = @affiliate
      end

      it "should display a link to the advanced search page" do
        render :locals => { :path => search_path, :search => @search, :affiliate => @affiliate }
        response.should contain(/Advanced Search/)
      end

      context "when a scope id is specified" do
        before do
          @search.stub!(:scope_id).and_return "SomeScope"
          assigns[:scope_id] = 'SomeScope'
        end

        it "should include a hidden tag with the scope id" do
          @search.scope_id.should == 'SomeScope'
          render :locals => { :path => search_path, :search => @search, :affiliate => @affiliate, :scope_id => 'SomeScope'}
          response.should have_tag('input[type=?][id=?][value=?]', 'hidden', 'scope_id', 'SomeScope')
        end
      end
    end
  end
end
