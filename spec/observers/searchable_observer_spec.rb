# frozen_string_literal: true

require 'spec_helper'

describe SearchableObserver do
  fixtures :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }

  describe 'retired models' do
    before do
      allow(ElasticFeaturedCollection).to receive(:index)
      allow(ElasticFeaturedCollection).to receive(:delete)
      allow(ElasticSaytSuggestion).to receive(:index)
      allow(ElasticSaytSuggestion).to receive(:delete)
    end

    it 'does not index or delete a FeaturedCollection on save and destroy' do
      featured_collection = affiliate.featured_collections.create!(title: 'Graphic best bet',
                                                                   status: 'active',
                                                                   publish_start_on: Date.current)
      featured_collection.update!(title: 'Updated graphic best bet')
      featured_collection.destroy

      expect(ElasticFeaturedCollection).not_to have_received(:index)
      expect(ElasticFeaturedCollection).not_to have_received(:delete)
    end

    it 'does not index or delete a SaytSuggestion on save and destroy' do
      sayt_suggestion = affiliate.sayt_suggestions.create!(phrase: 'retired suggestion')
      sayt_suggestion.update!(popularity: 5)
      sayt_suggestion.destroy

      expect(ElasticSaytSuggestion).not_to have_received(:index)
      expect(ElasticSaytSuggestion).not_to have_received(:delete)
    end
  end

  describe 'observed models' do
    before do
      allow(ElasticBoostedContent).to receive(:index)
      allow(ElasticBoostedContent).to receive(:delete)
    end

    it 'indexes and deletes a BoostedContent on save and destroy' do
      boosted_content = affiliate.boosted_contents.create!(title: 'Text best bet',
                                                           url: 'https://search.gov/best-bet',
                                                           description: 'Description',
                                                           status: 'active',
                                                           publish_start_on: Date.current)

      expect(ElasticBoostedContent).to have_received(:index)

      boosted_content.destroy

      expect(ElasticBoostedContent).to have_received(:delete).with(boosted_content.id)
    end
  end
end
