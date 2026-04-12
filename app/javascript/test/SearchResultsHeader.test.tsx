import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import SearchResultsHeader from '../components/SearchResultsHeader';

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
    searches: {
      menu: 'Menu',
      skipToMainContent: 'Skip to main content'
    },
    ariaLabelHeader: 'Primary navigation'
  }
};

describe('SearchResultsHeader', () => {
  it('renders the SERP header chrome through its own mount', () => {
    render(
      <SearchResultsHeader
        page={{
          affiliate: 'searchgov',
          displayLogoOnly: false,
          title: 'Search.gov',
          logo: {
            url: 'https://search.gov/logo.svg',
            text: 'search.gov'
          },
          homepageUrl: 'https://search.gov',
          showVoteOrgLink: false
        }}
        extendedHeader={false}
        translations={translations}
        fontsAndColors={fontsAndColors}
      />
    );

    expect(screen.getByText(/Search.gov/i)).toBeInTheDocument();
    expect(screen.getByText(/Skip to main content/i)).toBeInTheDocument();
  });
});
