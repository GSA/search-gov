require 'spec_helper'

describe OverallTopNQuery, "#body" do
  let(:query) { OverallTopNQuery.new(Date.parse('2014-06-28'), { field: 'raw', size: 1234 }) }

  subject(:body) { query.body }

  it { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must_not":{"term":{"tags":"api"}},"must":{"range":{"@timestamp":{"gte":"2014-06-28"}}}}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1234}}}}))}

end