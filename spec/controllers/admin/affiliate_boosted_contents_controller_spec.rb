# frozen_string_literal: true

describe Admin::AffiliateBoostedContentsController do
  let(:config) { described_class.active_scaffold_config }

  describe 'export columns' do
    it 'contains the correct columns in the correct order' do
      expect(config.export.columns.map(&:itself)).to eq(
        %i[
          title url description publish_start_on publish_end_on
          boosted_content_keywords match_keyword_values_only status
        ]
      )
    end
  end
end
