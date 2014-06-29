require 'spec_helper'

describe DateRangeTopNFieldQuery, "#body" do
  let(:query) { DateRangeTopNFieldQuery.new('foo', Date.parse("2014-06-28"), Date.parse("2014-06-29"), 'params.url', 'some_url', {field: 'raw', size: 0}) }

  subject(:body) { query.body }

  it { should == %q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"foo"}},{"term":{"params.url":"some_url"}},{"range":{"@timestamp":{"gte":"2014-06-28","lte":"2014-06-29"}}}]}}}},"aggs":{"agg":{"terms":{"field":"raw","size":0}}}})}

end