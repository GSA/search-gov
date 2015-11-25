require 'spec_helper'

describe KeenScopedKey do
  describe '.generate(affiliate_id)' do
    context 'success' do
      let(:mock_key) { mock("scoped key") }
      it "uses the master key to create a read-only scoped key" do
        options = { "filters" => [{ "property_name" => "affiliate_id", "operator" => "eq", "property_value" => 123 }],
                    "allowed_operations" => ["read"] }
        Keen::ScopedKey.should_receive(:new).with(Keen.master_key, options).and_return mock_key
        mock_key.should_receive(:encrypt!)
        KeenScopedKey.generate(123)
      end
    end

    context 'null affiliate_id passed in' do
      it "raises an exception" do
        lambda { KeenScopedKey.generate(nil) }.should raise_error(ArgumentError, "Affiliate ID required")
      end
    end
  end
end