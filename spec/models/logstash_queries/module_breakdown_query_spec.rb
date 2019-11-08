require 'spec_helper'

describe ModuleBreakdownQuery, "#body" do
  let(:query) { ModuleBreakdownQuery.new('affiliate_name') }

  subject(:body) { query.body }

  xit { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":{"term":{"affiliate":"affiliate_name"}},"must_not":{"term":{"useragent.device":"Spider"}}}}}},"aggs":{"agg":{"terms":{"field":"modules","size":0},"aggs":{"type":{"terms":{"field":"type"}}}}}}))}

end
