require 'spec_helper'

describe TemplatesHelper do
  describe "#generate_template_font_dropdown" do
    let(:default_font) { "Arial" }
    let(:font_family) {"Arial, Tahoma"}

    it "generates selected options" do
      expect(helper.generate_template_font_dropdown("Arial", "Arial, Tahoma")).to eq "<option selected='selected' value='Arial'>Arial</option><option value='Tahoma'>Tahoma</option>"
    end
  end

end
