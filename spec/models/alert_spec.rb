require 'spec_helper'

describe Alert do
  
  context "Validation" do
    context "When title and text are blank" do
      subject(:alert) { described_class.new(title: "", text: "", status: "Active") }
      it { is_expected.to be_valid }
    end
  end

  context "#renderable?" do
    context "When status is Inactive" do
      subject(:alert) { described_class.new(title: "aadsfas", text: "foo", status: "Inactive") }
      
      it "returns false" do
        expect(alert.renderable?).to be false
      end
    end

    context "When status is Active and title and text are not present" do
      subject(:alert) { described_class.new(title: "", text: "", status: "Active") }
      
      it "returns false" do
        expect(alert.renderable?).to be false
      end
    end

    context "When status is Active and title and text are present" do
      subject(:alert) { described_class.new(title: "Title", text: "foo", status: "Active") }
      
      it "returns true" do
        expect(alert.renderable?).to be true
      end
    end
  end
 
end
