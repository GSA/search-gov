/* eslint-disable camelcase */
import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';
import { LanguageContext } from '../contexts/LanguageContext';
import { SpellingSuggestion } from '../components/Results/SpellingSuggestion/SpellingSuggestion';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

const locale = {
  en: {
    showingResultsForMsg: 'No results found for \'%{original_query}\'. Showing results for %{corrected_query}',
    searchInsteadFor: 'Search instead for %{original_query}'
  }
};

const i18n = new I18n(locale);

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

interface clickDataProps {
  affiliate: string;
  url: string;
  module_code: string;
  position: number;
  query: string;
  vertical: string;
}

describe('SpellingSuggestion component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  const expectFetchtoHaveBeenCalledWith = (data: clickDataProps) => {
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(data),
      headers,
      method: 'POST',
      mode: 'cors'
    });
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  const spellingSuggestionProps = {
    suggested: '<a class="suggestedQuery" href="/search?affiliate=test_affiliate&amp;query=medical">medical</a>',
    original: '<a class="originalQuery" href="/search?affiliate=test_affiliate&amp;query=mecidal">mecidal</a>',
    originalUrl: '/search?affiliate=test_affiliate&query=mecidal',
    originalQuery: 'mecidal',
    suggestedQuery: 'medical',
    suggestedUrl: '/search?affiliate=test_affiliate&query=medical',
    affiliate: 'test_affiliate'
  };

  it('renders SpellingSuggestion component', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SpellingSuggestion {...spellingSuggestionProps} vertical='web' />
      </LanguageContext.Provider>
    );
  });

  it('Show original and suggested query', () => {
    const { container } = render(
      <LanguageContext.Provider value={i18n} >
        <SpellingSuggestion {...spellingSuggestionProps} vertical='web'/>
      </LanguageContext.Provider>
    );

    const suggestedQueryHtmlString = 'Showing results for <a class="suggestedQuery" href="/search?affiliate=test_affiliate&amp;query=medical">medical</a>';
    expect(container.innerHTML).toContain(suggestedQueryHtmlString);

    const originalQueryHtmlString = 'Search instead for <a class="originalQuery" href="/search?affiliate=test_affiliate&amp;query=mecidal">mecidal</a>';
    expect(container.innerHTML).toContain(originalQueryHtmlString);
  });

  it('clickTracking for suggestedQuery and originalQuery: web vertical', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SpellingSuggestion {...spellingSuggestionProps} vertical='web'/>
      </LanguageContext.Provider>
    );

    const suggestedQueryLink = screen.getByText(/medical/i);
    fireEvent.click(suggestedQueryLink);
    const clickBodySuggestedQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=medical',
      module_code: 'BSPEL',
      position: 1,
      query: 'medical',
      vertical: 'web'
    };
    expectFetchtoHaveBeenCalledWith(clickBodySuggestedQuery);

    const originalQueryLink = screen.getAllByText(/mecidal/i)[1];
    fireEvent.click(originalQueryLink);
    const clickBodyOriginalQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=mecidal',
      module_code: 'OVER',
      position: 1,
      query: 'mecidal',
      vertical: 'web'
    };
    expectFetchtoHaveBeenCalledWith(clickBodyOriginalQuery);
  });

  it('clickTracking for suggestedQuery and originalQuery: i14y vertical', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SpellingSuggestion {...spellingSuggestionProps} vertical='i14y'/>
      </LanguageContext.Provider>
    );

    const suggestedQueryLink = screen.getByText(/medical/i);
    fireEvent.click(suggestedQueryLink);
    const clickBodySuggestedQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=medical',
      module_code: 'SPEL',
      position: 1,
      query: 'medical',
      vertical: 'i14y'
    };
    expectFetchtoHaveBeenCalledWith(clickBodySuggestedQuery);

    const originalQueryLink = screen.getAllByText(/mecidal/i)[1];
    fireEvent.click(originalQueryLink);
    const clickBodyOriginalQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=mecidal',
      module_code: 'ISPEL',
      position: 1,
      query: 'mecidal',
      vertical: 'i14y'
    };
    expectFetchtoHaveBeenCalledWith(clickBodyOriginalQuery);
  });

  it('clickTracking for suggestedQuery and originalQuery: image vertical', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SpellingSuggestion {...spellingSuggestionProps} vertical='image'/>
      </LanguageContext.Provider>
    );

    const suggestedQueryLink = screen.getByText(/medical/i);
    fireEvent.click(suggestedQueryLink);
    const clickBodySuggestedQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=medical',
      module_code: 'OSPEL',
      position: 1,
      query: 'medical',
      vertical: 'image'
    };
    expectFetchtoHaveBeenCalledWith(clickBodySuggestedQuery);

    const originalQueryLink = screen.getAllByText(/mecidal/i)[1];
    fireEvent.click(originalQueryLink);
    const clickBodyOriginalQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=mecidal',
      module_code: 'LOVER',
      position: 1,
      query: 'mecidal',
      vertical: 'image'
    };
    expectFetchtoHaveBeenCalledWith(clickBodyOriginalQuery);
  });

  it('clickTracking for suggestedQuery and originalQuery: blended (or docs, news) vertical', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SpellingSuggestion {...spellingSuggestionProps} vertical='blended'/>
      </LanguageContext.Provider>
    );

    const suggestedQueryLink = screen.getByText(/medical/i);
    fireEvent.click(suggestedQueryLink);
    const clickBodySuggestedQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=medical',
      module_code: 'SPEL',
      position: 1,
      query: 'medical',
      vertical: 'blended'
    };
    expectFetchtoHaveBeenCalledWith(clickBodySuggestedQuery);

    const originalQueryLink = screen.getAllByText(/mecidal/i)[1];
    fireEvent.click(originalQueryLink);
    const clickBodyOriginalQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=mecidal',
      module_code: 'LOVER',
      position: 1,
      query: 'mecidal',
      vertical: 'blended'
    }; 
    expectFetchtoHaveBeenCalledWith(clickBodyOriginalQuery);
  });
});
