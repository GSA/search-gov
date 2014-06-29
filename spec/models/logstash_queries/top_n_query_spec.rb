require 'spec_helper'

describe TopNQuery, "#body" do
  let(:query) { TopNQuery.new('aff_name', {field: 'raw', size: 1000}) }

  subject(:body) { query.body }

  it { should == %q({"query":{"filtered":{"filter":{"bool":{"must":{"term":{"affiliate":"aff_name"}},"must_not":{"term":{"useragent.device":"Spider"}}}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1000}}}})}

end