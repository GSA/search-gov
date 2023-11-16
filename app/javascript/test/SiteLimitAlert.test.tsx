import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';
import { LanguageContext } from '../contexts/LanguageContext';
import { SiteLimitAlert } from '../components/Results/SiteLimitAlert/SiteLimitAlert';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

const locale = {
  en: {
    searches: { 
      siteLimits: {
        includingResultsForQueryFromMatchingSites: 'We\'re including results for %{query} from %{matching_sites} only',
        doYouWantToSeeResultsFor: 'Do you want to see results for %{query_from_all_sites}?',
        queryFromAllSites: '%{query} from all locations'
      } 
    }
  }
};

const i18n = new I18n(locale);

describe('Site limit Alert component', () => {
  it('renders site limit component', () => {
    render(
      <SiteLimitAlert 
        sitelimit='www.nps.gov/shen'
        url='/search?affiliate=nps&amp;query=trail+maps' 
        query='government' />
    );
  });

  it('shows the site limit help text', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <SiteLimitAlert 
        sitelimit='www.nps.gov/shen'
        url='/search?affiliate=nps&amp;query=trail+maps' 
        query='government' />
      </LanguageContext.Provider>
    );
    expect(screen.getByText('We\'re including results for government from www.nps.gov/shen only')).toBeInTheDocument();
  });
});
