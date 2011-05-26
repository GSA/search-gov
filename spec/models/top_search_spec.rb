require 'spec/spec_helper'

describe TopSearch do
  it { should validate_presence_of :position }
  it { should validate_numericality_of :position }
  it { should ensure_inclusion_of(:position).in_range(1..5).with_low_message(/must be greater than or equal/).with_high_message(/must be less than or equal/) }

  describe "#save" do
    it "should set query to nil if query is blank" do
      top_search = TopSearch.create!(:position => 1, :query => '  ')
      top_search.query.should be_nil
    end
  end

  describe "#find_active_entries" do
    it "should retrieve 5 entries with query that is not null, sorted by position in ascending order" do
      TopSearch.should_receive(:all).with(:conditions => "query IS NOT NULL", :order => "position ASC", :limit => 5)
      TopSearch.find_active_entries
    end
  end
end