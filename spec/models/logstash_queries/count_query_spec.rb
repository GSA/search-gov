require 'spec_helper'

describe CountQuery, "#body" do
  let(:query) { CountQuery.new('affiliate_name') }

  subject(:body) { query.body }

  it { should == %q({"query":{"filtered":{"filter":{"bool":{"must":{"term":{"affiliate":"affiliate_name"}},"must_not":{"term":{"useragent.device":"Spider"}}}}}}})}

end