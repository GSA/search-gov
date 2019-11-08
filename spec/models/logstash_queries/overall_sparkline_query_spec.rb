require 'spec_helper'

describe OverallSparklineQuery, "#body" do
  let(:query) { OverallSparklineQuery.new('affiliate_name') }

  subject(:body) { query.body }

  # SRCH-1044
  xit { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"affiliate_name"}},{"range":{"@timestamp":{"gte":"now-60d/d"}}},{"exists":{"field":"modules"}}],"must_not":{"term":{"useragent.device":"Spider"}}}}}},"aggs":{"histogram":{"date_histogram":{"field":"@timestamp","interval":"day","format":"yyyy-MM-dd","min_doc_count":0},"aggs":{"type":{"terms":{"field":"type"}}}}}}))}

end
