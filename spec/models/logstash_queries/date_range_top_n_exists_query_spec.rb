require 'spec_helper'

describe DateRangeTopNExistsQuery, "#body" do
  let(:query) { DateRangeTopNExistsQuery.new('aff_name', Date.new(2015, 6, 1), Date.new(2015, 6, 30), { field: 'raw', size: 1000 }) }

  subject(:body) { query.body.tap { |b| puts b } }

  it { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"aff_name"}},{"exists":{"field":"modules"}},{"range":{"@timestamp":{"gte":"2015-06-01","lte":"2015-06-30"}}}],"must_not":[{"term":{"useragent.device":"Spider"}},{"term":{"raw":""}},{"term":{"modules":"QRTD"}}]}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1000}}}}))}
end
