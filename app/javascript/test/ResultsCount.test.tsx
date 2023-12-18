import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';
import { LanguageContext } from '../contexts/LanguageContext';

import { ResultsCount } from '../components/Results/ResultsCount/ResultsCount';

const locale = {
  en: {
    searches: {
      resultsCount: {
        zero: '0 results',
        one: '1 result',
        other: '%{formatted_count} results'
      }
    }
  }
};

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

const i18n = new I18n(locale);

describe('ResultsCount component', () => {
  it('renders Results Count component', () => {
    render(
      <ResultsCount total={10}/>
    );
  });

  it('shows non-zero results', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <ResultsCount total={10500}/>
      </LanguageContext.Provider>
    );
    expect(screen.getByText('10,500 results')).toBeInTheDocument();
  });

  it('shows zero results', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <ResultsCount total={0}/>
      </LanguageContext.Provider>
    );
    expect(screen.getByText('0 results')).toBeInTheDocument();
  });

  it('shows 1 result', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <ResultsCount total={1}/>
      </LanguageContext.Provider>
    );
    expect(screen.getByText('1 result')).toBeInTheDocument();
  });
});
