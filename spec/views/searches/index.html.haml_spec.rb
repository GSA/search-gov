require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "searches/index.html.haml" do
  before do
    @search = stub("Search")
    assigns[:search] = @search
  end

  context "when spelling suggestion is available" do
    before do
      @search.stub!(:query).and_return "U mispeled everytheeng"
      @search.stub!(:spelling_suggestion).and_return "You misspelled everything"
      @search.stub!(:related_search).and_return []
      @search.stub!(:results).and_return []
      @search.stub!(:error_message).and_return "Ignore me"
    end

    it "should show the spelling suggestion" do
      render "searches/index.html.haml"
      response.should contain("You misspelled everything")
    end
  end
end