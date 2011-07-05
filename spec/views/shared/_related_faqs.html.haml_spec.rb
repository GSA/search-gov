require 'spec/spec_helper'
describe "shared/_related_faqs.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:queried_at_seconds).and_return(1271978870)
  end

  context "when there are related FAQ results" do
    before do
      @search.stub!(:query).and_return "<i>tax forms</i>"
      @faqs = Faq.search_for(@search.query)
      @faqs.stub!(:total).and_return 3
      @search.stub!(:faqs).and_return @faqs
      assign(:search, @search)
    end

    it "should display related FAQ results" do
      render
      rendered.should have_selector('h3', :content => 'Questions & Answers for <i>tax forms</i> by USA.gov')
      rendered.should have_selector('ul', :id => 'related_faqs')
    end
  end

  context "when there are no related FAQ results" do
    before do
      @search.stub!(:query).and_return "<i>tax forms</i>"
      @search.stub!(:faqs).and_return nil
      assign(:search, @search)
    end

    it "should not display related FAQ results" do
      render
      rendered.should_not have_selector('ul', :id => 'related_faqs')
    end
  end
end
