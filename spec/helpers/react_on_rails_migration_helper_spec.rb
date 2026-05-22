# frozen_string_literal: true

require 'spec_helper'

describe ReactOnRailsMigrationHelper do
  describe '#react_on_rails_component' do
    let(:view_proxy) { instance_double(ReactOnRailsMigrationHelper::ViewProxy) }

    before do
      allow(ReactOnRailsMigrationHelper::ViewProxy).to receive(:new).with(helper).and_return(view_proxy)
      allow(view_proxy).to receive(:react_component).and_return('')
    end

    around do |example|
      original_camelize_props = Rails.application.config.react.camelize_props
      Rails.application.config.react.camelize_props = true
      example.run
    ensure
      Rails.application.config.react.camelize_props = original_camelize_props
    end

    it 'preserves react-rails camelized props behavior' do
      helper.react_on_rails_component(
        'SearchResultsFooter',
        props: {
          translations: {
            en: {
              return_to_top: 'Return to top'
            }
          }
        }
      )

      expect(view_proxy).to have_received(:react_component).with(
        'SearchResultsFooter',
        hash_including(
          props: {
            'translations' => {
              'en' => {
                'returnToTop' => 'Return to top'
              }
            }
          }
        )
      )
    end
  end
end
