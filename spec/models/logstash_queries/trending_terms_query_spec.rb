require 'spec_helper'

describe TrendingTermsQuery, "#body" do
  let(:query) { TrendingTermsQuery.new('affiliate_name', '5h', 22) }

  subject(:body) { query.body }

  xit { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"affiliate_name"}},{"term":{"type":"search"}}],"must_not":[{"term":{"useragent.device":"Spider"}},{"term":{"raw":""}},{"exists":{"field":"params.page"}}]}},"query":{"range":{"@timestamp":{"gte":"now-5h/h"}}}}},"aggs":{"agg":{"significant_terms":{"min_doc_count":22,"field":"params.query.raw","background_filter":{"bool":{"must":[{"term":{"affiliate":"affiliate_name"}},{"term":{"type":"search"}}],"must_not":[{"term":{"useragent.device":"Spider"}},{"term":{"raw":""}},{"exists":{"field":"params.page"}}]}}},"aggs":{"clientip_count":{"cardinality":{"field":"clientip"}}}}}}))}

end
