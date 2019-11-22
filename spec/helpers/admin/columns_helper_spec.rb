require 'spec_helper'

describe Admin::ColumnsHelper do
  let(:column) { double(ActiveScaffold::DataStructures::Column) }

  describe "#affiliates_export_column(feature)" do
    fixtures :features, :affiliates
    before do
      @feature = features(:sayt)
      affiliates(:power_affiliate).features << @feature
      affiliates(:basic_affiliate).features << @feature
    end

    it "should return a comma-delimited string of alphabetized affiliate names using that feature" do
      expect(helper.affiliates_export_column(@feature)).to eq('noaa.gov,nps.gov')
    end
  end
end
