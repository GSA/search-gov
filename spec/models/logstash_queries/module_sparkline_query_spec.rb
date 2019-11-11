require 'spec_helper'

describe ModuleSparklineQuery, "#body" do
  let(:query) { ModuleSparklineQuery.new('affiliate_name') }

  subject(:body) { query.body }

  # SRCH-1042
  xit { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"affiliate_name"}},{"range":{"@timestamp":{"gte":"now-60d/d"}}},{"exists":{"field":"modules"}}],"must_not":{"term":{"useragent.device":"Spider"}}}}}},"aggs":{"agg":{"terms":{"field":"modules","size":0},"aggs":{"histogram":{"date_histogram":{"field":"@timestamp","interval":"day","format":"yyyy-MM-dd","min_doc_count":0},"aggs":{"type":{"terms":{"field":"type"}}}}}}}}))}

end
