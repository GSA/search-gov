import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';

import { VerticalNav } from '../components/VerticalNav/VerticalNav';
import { LanguageContext } from '../contexts/LanguageContext';
import { NavigationLink } from '../components/SearchResultsLayout';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

const locale = {
  en: {
    showMore: 'More',
    relatedSearches: 'Related Searches'
  }
};

const i18n = new I18n(locale);

describe('VerticalNav', () => {
  it('shows the vertical nav links', () => {
    const relatedSites = [{ label: 'Related Site 1', link: 'example.com' }];
    const navigationLinks = [{ label: 'all', active: true, href: 'http://search.gov' }];

    render(
      <LanguageContext.Provider value={i18n} >
        <VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
      </LanguageContext.Provider>
    );

    const all = screen.getByText(/all/i);
    expect(all).toBeInTheDocument();
    
    const moreLink = screen.getByText(/More/i);
    expect(moreLink).toBeInTheDocument();

    fireEvent.click(moreLink);

    const relatedSitesLink = screen.getByText(/Related Searches/i);
    expect(relatedSitesLink).toBeInTheDocument();

    const [relatedSitesChild] = screen.getAllByText(/Related Site 1/i);
    expect(relatedSitesChild).toBeInTheDocument();
  });

  describe('there is space to render all', () => {
    it('shows related searches button', ()=> {
      const relatedSites = [{ label: 'Related Site 1', link: 'example.com' }];
      const navigationLinks: NavigationLink[] = [];

      render(
        <LanguageContext.Provider value={i18n} >
          <VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
        </LanguageContext.Provider>
      );

      const relatedSitesLink = screen.getByText(/Related Searches/i);
      expect(relatedSitesLink).toBeInTheDocument();

      const [relatedSitesChild] = screen.getAllByText(/Related Site 1/i);
      expect(relatedSitesChild).toBeInTheDocument();
    });
  });
});
