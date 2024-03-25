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
    showingResultsFor: 'Showing results for %{corrected_query}',
    searchInsteadFor: 'Search instead for %{original_query}'
  }
};

const i18n = new I18n(locale);

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('SpellingSuggestion component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
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
    render(
      <LanguageContext.Provider value={i18n} >
        <SpellingSuggestion {...spellingSuggestionProps} vertical='web'/>
      </LanguageContext.Provider>
    );

    expect(screen.getByText('Showing results for')).toBeInTheDocument();
    expect(screen.getByText('medical')).toBeInTheDocument();
    const [suggestedQuery] = Array.from(document.getElementsByClassName('suggestedQuery'));
    expect(suggestedQuery).toHaveAttribute('href', '/search?affiliate=test_affiliate&query=medical');

    expect(screen.getByText('Search instead for')).toBeInTheDocument();
    expect(screen.getByText('mecidal')).toBeInTheDocument();
    const [originalQuery] = Array.from(document.getElementsByClassName('originalQuery'));
    expect(originalQuery).toHaveAttribute('href', '/search?affiliate=test_affiliate&query=mecidal');
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
 
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBodySuggestedQuery),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);

    const originalQueryLink = screen.getByText(/mecidal/i);
    fireEvent.click(originalQueryLink);
    const clickBodyOriginalQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=mecidal',
      module_code: 'OVER',
      position: 1,
      query: 'mecidal',
      vertical: 'web'
    };
 
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBodyOriginalQuery),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(2);
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
 
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBodySuggestedQuery),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);

    const originalQueryLink = screen.getByText(/mecidal/i);
    fireEvent.click(originalQueryLink);
    const clickBodyOriginalQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=mecidal',
      module_code: 'ISPEL',
      position: 1,
      query: 'mecidal',
      vertical: 'i14y'
    };
 
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBodyOriginalQuery),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(2);
  });

  it('clickTracking for suggestedQuery and originalQuery: images vertical', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SpellingSuggestion {...spellingSuggestionProps} vertical='images'/>
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
      vertical: 'images'
    };
 
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBodySuggestedQuery),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);

    const originalQueryLink = screen.getByText(/mecidal/i);
    fireEvent.click(originalQueryLink);
    const clickBodyOriginalQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=mecidal',
      module_code: 'LOVER',
      position: 1,
      query: 'mecidal',
      vertical: 'images'
    };
 
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBodyOriginalQuery),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(2);
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
 
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBodySuggestedQuery),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);

    const originalQueryLink = screen.getByText(/mecidal/i);
    fireEvent.click(originalQueryLink);
    const clickBodyOriginalQuery = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search?affiliate=test_affiliate&query=mecidal',
      module_code: 'LOVER',
      position: 1,
      query: 'mecidal',
      vertical: 'blended'
    };
 
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBodyOriginalQuery),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(2);
  });
});
