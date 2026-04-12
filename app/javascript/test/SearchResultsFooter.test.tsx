import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import SearchResultsFooter from '../components/SearchResultsFooter';

jest.mock('i18n-js', () => jest.requireActual('i18n-js/dist/require/index'));

const fontsAndColors = {
  activeSearchTabNavigationColor: '#1f1748',
  bannerBackgroundColor: '#643617',
  bannerTextColor: '#dacb1b',
  bestBetBackgroundColor: '#6e09bf',
  buttonBackgroundColor: '#cfcd03',
  footerAndResultsFontFamily: '"Helvetica Neue", "Helvetica", "Roboto", "Arial", sans-serif',
  footerBackgroundColor: '#5fcfc5',
  footerLinksTextColor: '#46f966',
  headerBackgroundColor: '#4a402b',
  headerLinksFontFamily: '"Georgia", "Cambria", "Times New Roman", "Times", serif',
  headerNavigationBackgroundColor: '#83df0a',
  headerPrimaryLinkColor: '#594973',
  headerSecondaryLinkColor: '#c8155d',
  headerTextColor: '#C000FE',
  healthBenefitsHeaderBackgroundColor: '#abb178',
  pageBackgroundColor: '#761816',
  primaryNavigationFontFamily: '"Public Sans Web"',
  primaryNavigationFontWeight: 'bold',
  resultDescriptionColor: '#2bd4c7',
  resultTitleColor: '#33f0aa',
  resultTitleLinkVisitedColor: '#4a97ad',
  resultUrlColor: '#475830',
  searchTabNavigationLinkColor: '#aea9f7',
  sectionTitleColor: '#8b4a35'
};

const translations = {
  en: {
    returnToTop: 'Return to top'
  }
};

describe('SearchResultsFooter', () => {
  it('renders the SERP footer chrome through its own mount', () => {
    render(
      <SearchResultsFooter
        footerLinks={[{ title: 'first footer link', url: 'https://first.gov' }]}
        translations={translations}
        fontsAndColors={fontsAndColors}
      />
    );

    expect(screen.getByText(/first footer link/i)).toHaveAttribute('href', 'https://first.gov');
    expect(screen.getByText(/Return to top/i)).toBeInTheDocument();
  });
});
