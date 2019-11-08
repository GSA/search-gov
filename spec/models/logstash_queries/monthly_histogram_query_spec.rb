require 'spec_helper'

describe MonthlyHistogramQuery, "#body" do
  let(:query) { MonthlyHistogramQuery.new('affiliate_name', Date.parse('2014-06-28')) }

  subject(:body) { query.body }

  xit { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"affiliate_name"}},{"range":{"@timestamp":{"gte":"2014-06-28"}}}],"must_not":{"term":{"useragent.device":"Spider"}}}}}},"aggs":{"agg":{"date_histogram":{"field":"@timestamp","interval":"month","format":"yyyy-MM","min_doc_count":0}}}}))}

end
