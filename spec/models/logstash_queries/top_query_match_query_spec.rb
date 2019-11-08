require 'spec_helper'

describe TopQueryMatchQuery, "#body" do
  let(:query) { TopQueryMatchQuery.new('foo', 'my query term', Date.parse("2014-06-28"), Date.parse("2014-06-29"), {field: 'raw', size: 1000}) }

  subject(:body) { query.body }

  xit { is_expected.to eq(%q({"query":{"filtered":{"query":{"match":{"query":{"query":"my query term","analyzer":"snowball","operator":"and"}}},"filter":{"bool":{"must":[{"term":{"affiliate":"foo"}},{"range":{"@timestamp":{"gte":"2014-06-28","lte":"2014-06-29"}}}],"must_not":{"term":{"useragent.device":"Spider"}}}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1000},"aggs":{"type":{"terms":{"field":"type"}}}}}}))}

end
