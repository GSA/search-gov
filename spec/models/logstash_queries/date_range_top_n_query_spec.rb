require 'spec_helper'

describe DateRangeTopNQuery, "#body" do
  let(:query) { DateRangeTopNQuery.new('foo', Date.parse("2014-06-28"), Date.parse("2014-06-29"), {field: 'raw', size: 1000}) }

  subject(:body) { query.body }

  it { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"foo"}},{"range":{"@timestamp":{"gte":"2014-06-28","lte":"2014-06-29"}}}],"must_not":{"term":{"useragent.device":"Spider"}}}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1000}}}}))}

end