require 'spec_helper'
describe "shared/_search.html.haml" do
  before do
    @search = double("Search")
    @search.stub(:query).and_return nil
    @search.stub(:filter_setting).and_return nil
    @search.stub(:scope_id).and_return nil
    assign(:search, @search)
    view.stub(:path).and_return search_path
  end

  context "when page is displayed" do
    before do
      @affiliate = double('Affiliate', :name => 'aff.gov', :is_sayt_enabled => false)
      assign(:affiliate, @affiliate)
    end

    context "when a scope id is specified" do
      before do
        @search.stub(:scope_id).and_return "SomeScope"
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
