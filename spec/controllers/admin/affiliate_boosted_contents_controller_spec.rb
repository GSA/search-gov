require 'spec/spec_helper'

describe Admin::AffiliateBoostedContentsController do
  describe "#after_create_save" do
    it "should tell Sunspot to reindex" do
      bc = BoostedContent.new
      Sunspot.should_receive(:index).with(bc).and_return true
      controller.after_create_save(bc)
    end
  end
  
  describe "#after_update_save" do
    it "should tell Sunspot to reindex" do
      bc = BoostedContent.new
      Sunspot.should_receive(:index).with(bc).and_return true
      controller.after_update_save(bc)
    end
  end
end
