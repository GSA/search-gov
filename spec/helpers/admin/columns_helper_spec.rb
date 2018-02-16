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

  describe "#nutshell_column" do
    context "when the record is a User" do
      fixtures :users

      context "and it has a nutshell_id" do
        let(:record) { users(:affiliate_manager) }

        it "should be a link to the Nutshell contact" do
          expect(helper.nutshell_column(record, column)).to have_selector('a[href="https://app.nutshell.com/contact/1001"][target="_blank"]', text: '1001')
        end
      end

      context "but it doesn't have a nutshell_id" do
        let(:record) { users(:another_affiliate_manager) }

        it "should be nil" do
          expect(helper.nutshell_column(record, column)).to eq(nil)
        end
      end
    end

    context "when the record is an Affiliate" do
      fixtures :affiliates

      context "and it has a nutshell_id" do
        let(:record) { affiliates(:basic_affiliate) }

        it "should be a link to the Nutshell lead" do
          expect(helper.nutshell_column(record, column)).to have_selector('a[href="https://app.nutshell.com/lead/id/99"][target="_blank"]', text: '99')
        end
      end

      context "but it doesn't have a nutshell_id" do
        let(:record) { affiliates(:another_affiliate) }

        it "should be nil" do
          expect(helper.nutshell_column(record, column)).to eq(nil)
        end
      end
    end
  end
end
