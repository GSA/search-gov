import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';

import * as VNav from '../components/VerticalNav/VerticalNav';
import { LanguageContext } from '../contexts/LanguageContext';
import { NavigationLink } from '../components/SearchResultsLayout';

jest.mock('i18n-js', () => jest.requireActual('i18n-js/dist/require/index'));

const locale = {
  en: {
    searches: { relatedSites: 'View More' },
    showMore: 'More'
  },
};

const i18n = new I18n(locale);

describe('VerticalNav', () => {
  it('shows the vertical nav link with related site in the menu', () => {
    const relatedSites = [{ label: 'Related Site 1', link: 'example.com' }];
    const navigationLinks = [{ label: 'all', active: true, href: 'http://search.gov' }];

    jest.spyOn(VNav, 'isThereEnoughSpace').mockReturnValue(true);

    render(
      <LanguageContext.Provider value={i18n} >
        <VNav.VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
      </LanguageContext.Provider>
    );

    const all = screen.getByText(/all/i);
    expect(all).toBeInTheDocument();
    
    const moreLink = screen.getByText(/Related Site 1/i);
  });

  describe('there is space to render only one tab', () => {
    it('shows tab and more button', () => {
      jest.spyOn(VNav, 'isThereEnoughSpace').mockReturnValueOnce(true).mockReturnValue(false);

      const relatedSites = [{ label: 'Related Site 1', link: 'example.com' }];
      const navigationLinks = [{ label: 'all', active: true, href: 'http://search.gov' }, { label: 'other', active: false, href: 'http://other.gov' }];

      render(
        <LanguageContext.Provider value={i18n} >
          <VNav.VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} />
        </LanguageContext.Provider>
      );

      const all = screen.getByText(/all/i);
      expect(all).toBeInTheDocument();

      const moreLink = screen.getByText(/More/i);
      expect(moreLink).toBeInTheDocument();

      const [relatedSitesChild] = screen.getAllByText(/Related Site 1/i);
      expect(relatedSitesChild).toBeInTheDocument();
    });
  });
});
