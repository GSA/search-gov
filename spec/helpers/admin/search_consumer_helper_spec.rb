require 'spec_helper'

describe Admin::SearchConsumerHelper do
  fixtures :affiliates

  describe "#selected_template_dropdown_options" do
    let(:affiliate) { affiliates(:usagov_affiliate) }

    it "generates selected options" do
      affiliate.template
      expect(helper.selected_template_dropdown_options(affiliate)).to eq "<option selected='selected' value='Template::Classic'>Classic</option>"
    end
  end
end