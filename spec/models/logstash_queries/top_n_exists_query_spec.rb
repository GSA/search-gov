require 'spec_helper'

describe TopNExistsQuery, "#body" do
  let(:query) { TopNExistsQuery.new('aff_name', {field: 'raw', size: 1000}) }

  subject(:body) { query.body }

  it { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"aff_name"}},{"exists":{"field":"modules"}}],"must_not":[{"term":{"useragent.device":"Spider"}},{"term":{"raw":""}},{"term":{"modules":"QRTD"}}]}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1000}}}}))}

end