require 'spec_helper'

describe TopNMissingQuery, "#body" do
  let(:query) { TopNMissingQuery.new('aff_name', {field: 'raw', size: 1000}) }

  subject(:body) { query.body }

  it { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"aff_name"}},{"missing":{"field":"modules"}}],"must_not":[{"term":{"useragent.device":"Spider"}},{"term":{"raw":""}}]}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1000}}}}))}

end