# coding: utf-8
require 'spec_helper'

describe 'shared/_related_topics.html.haml' do
  fixtures :affiliates

  before do
    @search = double('Search')
    allow(@search).to receive(:queried_at_seconds).and_return(1271978870)
    allow(@search).to receive(:query).and_return '<i>tax forms</i>'
    allow(@search).to receive(:spelling_suggestion).and_return nil
    assign(:search, @search)
    assign(:affiliate, affiliates(:usagov_affiliate))
  end

  context 'when there are related topics' do
    before do
      @related_searches = ['first-1 keeps the hyphen', 'second one is a string', 'CIA gets downcased', 'utilización de gafas del sol durante el tiempo']
      allow(@search).to receive(:related_search).and_return @related_searches
      allow(@search).to receive(:has_related_searches?).and_return true
    end

    it  'should display related topics' do
      render
      expect(rendered).to have_selector('#related_searches')
      expect(rendered).to have_selector('h3', text: %q{Related Searches for '<i>tax forms</i>'})
      expect(rendered).to have_selector('a', text: 'cia gets downcased')
      expect(rendered).to have_selector('a', text: 'first-1 keeps the hyphen')
      expect(rendered).to have_selector('a', text: 'second one is a string')
      expect(rendered).to have_selector('a', text: 'utilización de gafas del sol durante el tiempo')
    end
  end

  context 'when there are no related topics' do
    before do
      @related_searches = []
      allow(@search).to receive(:related_search).and_return @related_searches
      allow(@search).to receive(:has_related_searches?).and_return false
    end

    it  'should not display related topics' do
      render
      expect(rendered).not_to have_selector('#related_searches')
    end
  end

end
