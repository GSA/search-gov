require 'spec/spec_helper'
describe "shared/_search.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:query).and_return nil
    @search.stub!(:filter_setting).and_return nil
    @search.stub!(:scope_id).and_return nil
    @search.stub!(:fedstates).and_return nil
    assign(:search, @search)
    view.stub!(:path).and_return search_path
    view.stub!(:web_search?).and_return true
  end

  context "when page is displayed" do
    it "should display a link to the advanced search page" do
      render
      rendered.should contain(/Advanced Search/)
    end

    context "for an affiliate site" do
      before do
        @affiliate = stub('Affiliate')
        @affiliate.stub!(:name).and_return 'aff.gov'
        @affiliate.stub!(:is_sayt_enabled).and_return false
        assign(:affiliate, @affiliate)
      end

      it "should display a link to the advanced search page" do
        render
        rendered.should contain(/Advanced Search/)
      end

      context "when a scope id is specified" do
        before do
          @search.stub!(:scope_id).and_return "SomeScope"
          assign(:scope_id, 'SomeScope')
        end

        it "should include a hidden tag with the scope id" do
          @search.scope_id.should == 'SomeScope'
          render
          rendered.should have_selector("input[type='hidden'][id='scope_id'][value='SomeScope']")
        end
      end
    end
  end
end
