require 'spec_helper'

describe Admin::ColumnsHelper do
  let(:column) { mock(ActiveScaffold::DataStructures::Column) }

  describe "#affiliates_export_column(feature)" do
    fixtures :features, :affiliates
    before do
      @feature = features(:sayt)
      affiliates(:power_affiliate).features << @feature
      affiliates(:basic_affiliate).features << @feature
    end

    it "should return a comma-delimited string of alphabetized affiliate names using that feature" do
      helper.affiliates_export_column(@feature).should == 'noaa.gov,nps.gov'
    end
  end

  describe "#nutshell_column" do
    context "when the record is a User" do
      fixtures :users

      context "and it has a nutshell_id" do
        let(:record) { users(:affiliate_manager) }

        it "should be a link to the Nutshell contact" do
          helper.nutshell_column(record, column).should == '<a href="https://app.nutshell.com/contact/1001" target="_blank">1001</a>'
        end
      end

      context "but it doesn't have a nutshell_id" do
        let(:record) { users(:another_affiliate_manager) }

        it "should be nil" do
          helper.nutshell_column(record, column).should == nil
        end
      end
    end

    context "when the record is an Affiliate" do
      fixtures :affiliates

      context "and it has a nutshell_id" do
        let(:record) { affiliates(:basic_affiliate) }

        it "should be a link to the Nutshell lead" do
          helper.nutshell_column(record, column).should == '<a href="https://app.nutshell.com/lead/id/99" target="_blank">99</a>'
        end
      end

      context "but it doesn't have a nutshell_id" do
        let(:record) { affiliates(:another_affiliate) }

        it "should be nil" do
          helper.nutshell_column(record, column).should == nil
        end
      end
    end
  end

  describe "#templates_column" do
    let(:affiliate) do
      stub_model(Affiliate) { |affiliate| affiliate.id = 666 }
    end

    context "for a search consumer enabled affiliate" do
      before { affiliate.search_consumer_search_enabled = true }

      it "is a link to that affiliate's templates page" do
        expect(
          helper.templates_column(affiliate, column)
        ).to eq '<a href="/admin/affiliates/666/search_consumer_templates" target="_blank">Edit Templates</a>'
      end
    end

    context 'for a basic affiliate' do
      before { affiliate.search_consumer_search_enabled = false }

      it 'is nil' do
        expect(helper.templates_column(affiliate, column)).to be_nil
      end
    end
  end
end
