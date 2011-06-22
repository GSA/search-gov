require 'spec/spec_helper'

describe Admin::SpotlightsController do
  describe "#clean_params" do
    it "should remove any parameters from params that match the regex /record.*html_editor/" do
      controller.params["record_7_html_editor"] = "test"
      controller.clean_params
      controller.params["record_7_html_editor"].should be_nil
    end
  end
end
