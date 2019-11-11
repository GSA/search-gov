require 'spec_helper'

describe RtuDateRangeQuery, "#body" do
  let(:query) { RtuDateRangeQuery.new('affiliate_name') }

  subject(:body) { query.body }

  # SRCH-1045
  xit { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":{"term":{"affiliate":"affiliate_name"}},"must_not":{"term":{"useragent.device":"Spider"}}}}}},"facets":{"stats":{"statistical":{"field":"@timestamp"}}}}))}

end
