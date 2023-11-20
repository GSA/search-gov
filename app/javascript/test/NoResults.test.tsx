import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';
import { NoResults } from '../components/Results/NoResults/NoResults';
import { LanguageContext } from '../contexts/LanguageContext';

const locale = {
  en: {
    emptyQuery: 'Please enter a search term in the box above.'
  }
};

const noResultsMessageProp = {
  text: 'There are no results',
  urls: [
    { title: 'First Link', url: 'http://www.search.gov' },
    { title: 'First message' }
  ]
};

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

const i18n = new I18n(locale);

describe('NoResults', () => {
  it('NoResults with no additional message', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <NoResults errorMsg="no results for this search" />
      </LanguageContext.Provider>
    );
    const noResultsMessage = screen.getByText(/no results for this search/i);
    expect(noResultsMessage).toBeInTheDocument();
  });

  it('NoResults with additional message', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <NoResults errorMsg="no results for this search" noResultsMessage={noResultsMessageProp} />
      </LanguageContext.Provider>
    );
    const noResultsMessage = screen.getByText(/no results for this search/i);
    const additionalMessage = screen.getByText(/There are no results/i);
    const link = screen.getByText(/First Link/i);
    const message = screen.getByText(/First message/i);
    expect(noResultsMessage).toBeInTheDocument();
    expect(additionalMessage).toBeInTheDocument();
    expect(link).toBeInTheDocument();
    expect(message).toBeInTheDocument();
  });
});
