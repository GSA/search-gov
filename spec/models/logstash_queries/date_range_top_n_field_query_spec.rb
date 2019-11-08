require 'spec_helper'

describe DateRangeTopNFieldQuery do
  let(:query) do
    DateRangeTopNFieldQuery.new('affiliate_name',
                                Date.parse('2014-06-28'),
                                Date.parse('2014-06-29'),
                                'params.url',
                                'some_url',
                                { field: 'params.query.raw', size: 0 })
  end

  # SRCH-1039
  xit { is_expected.to eq(%q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"affiliate":"foo"}},{"term":{"params.url":"some_url"}},{"range":{"@timestamp":{"gte":"2014-06-28","lte":"2014-06-29"}}}]}}}},"aggs":{"agg":{"terms":{"field":"raw","size":0}}}}))}

  context 'when the affiliate is nil' do
    let(:query) do
      DateRangeTopNFieldQuery.new(nil,
                                  Date.parse("2014-06-28"),
                                  Date.parse("2014-06-29"),
                                  'some_field',
                                  'some_value',
                                  { field: 'raw', size: 0 })
    end

    # SRCH-1039
    xit 'filters by the field' do
      expect(body).to eq(
        %q({"query":{"filtered":{"filter":{"bool":{"must":[{"term":{"some_field":"some_value"}},{"range":{"@timestamp":{"gte":"2014-06-28","lte":"2014-06-29"}}}]}}}},"aggs":{"agg":{"terms":{"field":"raw","size":0}}}})
      )
    end
  end
end
