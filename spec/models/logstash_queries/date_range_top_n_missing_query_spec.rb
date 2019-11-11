require 'spec_helper'

describe DateRangeTopNMissingQuery, '#body' do
  let(:query) { DateRangeTopNMissingQuery.new('aff_name', Date.new(2015, 6, 1), Date.new(2015, 6, 30), { field: 'raw', size: 1000 }) }

  subject(:body) { query.body }

  # SRCH-1040
  xit { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"aff_name"}},{"missing":{"field":"modules"}},{"range":{"@timestamp":{"gte":"2015-06-01","lte":"2015-06-30"}}}],"must_not":[{"term":{"useragent.device":"Spider"}},{"term":{"raw":""}}]}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1000}}}}))}
end
